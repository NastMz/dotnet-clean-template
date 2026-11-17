using Application.Abstractions.Messaging;
using Application.ModuleName.FeatureName;
using SharedKernel;
using Web.Api.Extensions;
using Web.Api.Infrastructure;

namespace Web.Api.Endpoints.ModuleName;

internal sealed class FeatureName : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
#if (isQuery)
        app.MapGet("module-route/{id:guid}/feature-route", async (
            Guid id,
            IQueryHandler<FeatureNameQuery, ResponseType> handler,
            CancellationToken cancellationToken) =>
        {
            var query = new FeatureNameQuery(id);

            Result<ResponseType> result = await handler.Handle(query, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
#elif (hasResponseType)
        app.MapPost("module-route/{id:guid}/feature-route", async (
            Guid id,
            ICommandHandler<FeatureNameCommand, ResponseType> handler,
            CancellationToken cancellationToken) =>
        {
            var command = new FeatureNameCommand(id);

            Result<ResponseType> result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
#else
        app.MapPost("module-route/{id:guid}/feature-route", async (
            Guid id,
            ICommandHandler<FeatureNameCommand> handler,
            CancellationToken cancellationToken) =>
        {
            var command = new FeatureNameCommand(id);

            Result result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.NoContent, CustomResults.Problem);
        })
#endif
        .WithTags("ModuleName")
        .RequireAuthorization();
    }
}
