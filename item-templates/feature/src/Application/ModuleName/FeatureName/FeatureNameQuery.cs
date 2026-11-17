using Application.Abstractions.Messaging;

namespace Application.ModuleName.FeatureName;

public sealed record FeatureNameQuery(Guid Id) : IQuery<ResponseType>;
