using Application.Abstractions.Caching;
using Microsoft.Extensions.Caching.Hybrid;

namespace Infrastructure.Caching;

internal sealed class HybridCacheAdapter(HybridCache cache) : ICache
{
    public Task<T> GetOrCreateAsync<T>(
        string key,
        Func<CancellationToken, Task<T>> factory,
        TimeSpan? expiration = null,
        CancellationToken cancellationToken = default)
    {
        HybridCacheEntryOptions? options = expiration.HasValue
            ? new HybridCacheEntryOptions
            {
                Expiration = expiration.Value
            }
            : null;

        return cache.GetOrCreateAsync(
            key,
            cancel => new ValueTask<T>(factory(cancel)),
            options,
            cancellationToken: cancellationToken).AsTask();
    }
}
