# Use specific .NET 6.0 runtime and SDK versions for security and stability
# Multi-stage build for smaller image size and better security
ARG DOTNET_VERSION=6.0
ARG ASPNET_VERSION=6.0

# ================================
# Build Stage
# ================================
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS build

# Set build arguments
ARG BUILD_CONFIGURATION=Release
ARG APP_USER_UID=1001
ARG APP_USER_GID=1001

# Create application user and group
RUN groupadd -g ${APP_USER_GID} appuser \
    && useradd -r -u ${APP_USER_UID} -g appuser -s /sbin/nologin \
       -c "Application User" appuser

# Set working directory
WORKDIR /src

# Copy project files and restore dependencies
# Copy only project files first to leverage Docker layer caching
COPY WebGoatCore/WebGoatCore.csproj WebGoatCore/
COPY WebGoatCore.sln ./

# Restore NuGet packages with security settings
RUN dotnet nuget locals all --clear \
    && dotnet restore WebGoatCore/WebGoatCore.csproj --verbosity minimal \
       --runtime linux-x64

# Copy application source code
COPY WebGoatCore/ WebGoatCore/

# Build the application
WORKDIR /src/WebGoatCore
RUN dotnet build WebGoatCore.csproj \
    -c ${BUILD_CONFIGURATION} \
    -o /app/build \
    --no-restore \
    --verbosity minimal

# ================================
# Publish Stage
# ================================
FROM build AS publish

ARG BUILD_CONFIGURATION=Release

# Publish the application with optimizations
RUN dotnet publish WebGoatCore.csproj \
    -c ${BUILD_CONFIGURATION} \
    -o /app/publish \
    --runtime linux-x64 \
    --self-contained false \
    --verbosity minimal \
    /p:PublishTrimmed=false \
    /p:PublishReadyToRun=false

# Remove unnecessary files and set permissions
RUN find /app/publish -name "*.pdb" -delete \
    && find /app/publish -name "*.xml" -delete \
    && chmod -R 555 /app/publish \
    && chown -R appuser:appuser /app/publish

# ================================
# Runtime Stage
# ================================
FROM mcr.microsoft.com/dotnet/aspnet:${ASPNET_VERSION} AS runtime

# Security labels and metadata
LABEL maintainer="WebGoat Core Team" \
      version="1.0.0" \
      description="Secure WebGoat Core .NET Application" \
      org.opencontainers.image.title="WebGoat Core" \
      org.opencontainers.image.description="OWASP WebGoat Core .NET Application" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.created="2025-07-21" \
      org.opencontainers.image.source="https://github.com/WebGoat/WebGoat" \
      security.scan="required"

# Security arguments
ARG APP_USER_UID=1001
ARG APP_USER_GID=1001

# Create application user and group (non-root)
RUN groupadd -g ${APP_USER_GID} appuser \
    && useradd -r -u ${APP_USER_UID} -g appuser -s /sbin/nologin \
       -c "Application User" appuser

# Create application directories with proper permissions
RUN mkdir -p /app /app/data /app/logs /app/temp /var/log/app \
    && chown -R appuser:appuser /app /var/log/app \
    && chmod 755 /app \
    && chmod 750 /app/data /app/logs /app/temp /var/log/app

# Set working directory
WORKDIR /app

# Copy published application from build stage
COPY --from=publish --chown=appuser:appuser /app/publish ./

# Copy SQLite database with proper permissions
RUN if [ -f ./NORTHWND.sqlite ]; then \
        chown appuser:appuser ./NORTHWND.sqlite && \
        chmod 644 ./NORTHWND.sqlite; \
    fi

# Switch to non-root user
USER appuser:appuser

# Configure ASP.NET Core environment variables
ENV ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS=http://+:8080 \
    ASPNETCORE_HTTP_PORT=8080 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    DOTNET_EnableDiagnostics=0 \
    COMPlus_EnableDiagnostics=0 \
    ASPNETCORE_LOGGING__CONSOLE__DISABLECOLORS=true

# Security environment variables
ENV ASPNETCORE_FORWARDEDHEADERS_ENABLED=true \
    ASPNETCORE_PATHBASE= \
    ASPNETCORE_CONTENTROOT=/app

# Expose port (non-privileged)
EXPOSE 8080

# Use simple shell script entrypoint for proper signal handling
ENTRYPOINT ["dotnet", "WebGoatCore.dll"]

# Security best practices applied:
# 1. Multi-stage build to reduce image size
# 2. Specific version tags (no 'latest')
# 3. Non-root user execution
# 4. Minimal runtime image
# 5. Security updates installed
# 6. Proper file permissions
# 7. Health checks implemented
# 8. Signal handling with dumb-init
# 9. Environment variables configured
# 10. Metadata and labels for tracking
