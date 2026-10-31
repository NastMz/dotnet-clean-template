using Application.Abstractions.Caching;
using Application.Abstractions.Messaging;
using SharedKernel;

namespace Application.Abstractions.Behaviors;

internal static class CachingDecorator
{
    internal sealed class QueryHandler<TQuery, TResponse>(
        IQueryHandler<TQuery, TResponse> innerHandler,
        ICache cache)
        : IQueryHandler<TQuery, TResponse>
        where TQuery : IQuery<TResponse>
    {
        public async Task<Result<TResponse>> Handle(TQuery query, CancellationToken cancellationToken)
        {
            if (query is not ICacheableQuery cacheableQuery)
            {
                return await innerHandler.Handle(query, cancellationToken);
            }

            // Only successful values are cached. A failed result is surfaced through an exception so the
            // cache does not store it, and is then returned to the caller unchanged.
            try
            {
                TResponse response = await cache.GetOrCreateAsync(
                    cacheableQuery.CacheKey,
                    async token =>
                    {
                        Result<TResponse> result = await innerHandler.Handle(query, token);

                        return result.IsSuccess ? result.Value : throw new FailedResultException(result);
                    },
                    cacheableQuery.Expiration,
                    cancellationToken);

                return Result.Success(response);
            }
            catch (FailedResultException exception)
            {
                return (Result<TResponse>)exception.Result;
            }
        }
    }

#pragma warning disable CA1032, CA1064, S3871 // Private control-flow exception, never exposed to callers.
    private sealed class FailedResultException(Result result) : Exception
    {
        public Result Result { get; } = result;
    }
#pragma warning restore CA1032, CA1064, S3871
}
