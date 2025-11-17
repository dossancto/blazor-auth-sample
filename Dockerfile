FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["salve.sln", "."]
COPY ["salve/salve.csproj", "salve/"]
COPY ["salve.Client/salve.Client.csproj", "salve.Client/"]
RUN dotnet restore "./salve.sln"
COPY . .
WORKDIR "/src/."
RUN dotnet build "salve.sln" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "salve/salve.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS http://+:8080
ENV ASPNETCORE_ENVIRONMENT Production
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "salve.dll"]
