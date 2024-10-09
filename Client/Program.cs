using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using BlazorApp.Client;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(builder.Configuration["API_Prefix"] ?? builder.HostEnvironment.BaseAddress) });

builder.Services.AddMsalAuthentication(options =>
{
    builder.Configuration.Bind("AzureAd", options.ProviderOptions.Authentication);
    //options.ProviderOptions.DefaultAccessTokenScopes.Add("https://graph.microsoft.com/User.Read");
});

builder.Services.AddAuthorizationCore(opt => {
    opt.AddPolicy("Admin", policy => 
    {
        var groupId = builder.Configuration["Groups:AdminMyStaticBlazorAppId"];
        policy.RequireAssertion(context => context.User.HasClaim(c => 
            c.Type == "groups" && c.Value.Contains(groupId)));
    });
});

await builder.Build().RunAsync();
