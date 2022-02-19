FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /app
COPY . ./
RUN dotnet publish src/ConsoleApp/ConsoleApp.csproj -c Release -o out

#Generate run time image
FROM mcr.microsoft.com/dotnet/runtime:5.0
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "Bcan.ConsoleApp.dll"]