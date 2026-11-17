using Application.Abstractions.Messaging;
using SharedKernel;

namespace Application.ModuleName.FeatureName;

internal sealed class FeatureNameQueryHandler : IQueryHandler<FeatureNameQuery, ResponseType>
{
    public Task<Result<ResponseType>> Handle(FeatureNameQuery query, CancellationToken cancellationToken)
    {
        // Inject the dependencies you need (for example IApplicationDbContext) through the primary constructor
        // and replace this placeholder with a read-only projection.
        return Task.FromResult(Result.Failure<ResponseType>(
            Error.Failure("ModuleName.FeatureName.NotImplemented", "FeatureName is not implemented yet.")));
    }
}
