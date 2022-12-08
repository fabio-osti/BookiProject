FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
ARG PORT=8080
WORKDIR /app
EXPOSE ${PORT}

ENV ASPNETCORE_URLS=http://0.0.0.0:${PORT}

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["BookiApi.csproj", "./"]
RUN dotnet restore "BookiApi.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "BookiApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BookiApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BookiApi.dll"]
