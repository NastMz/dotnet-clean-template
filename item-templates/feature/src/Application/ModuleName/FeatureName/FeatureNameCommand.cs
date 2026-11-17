using Application.Abstractions.Messaging;

namespace Application.ModuleName.FeatureName;

#if (hasResponseType)
public sealed record FeatureNameCommand(Guid Id) : ICommand<ResponseType>;
#else
public sealed record FeatureNameCommand(Guid Id) : ICommand;
#endif
