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
        public Task<Result<TResponse>> Handle(TQuery query, CancellationToken cancellationToken)
        {
            if (query is not ICacheableQuery cacheableQuery)
            {
                return innerHandler.Handle(query, cancellationToken);
            }

            return cache.GetOrCreateAsync(
                cacheableQuery.CacheKey,
                token => innerHandler.Handle(query, token),
                cacheableQuery.Expiration,
                cancellationToken);
        }
    }
}
