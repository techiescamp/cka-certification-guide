# Build stage
FROM eclipse-temurin:25-jdk-alpine AS build
WORKDIR /app
COPY staff-registry-app/pom.xml .
COPY staff-registry-app/src ./src

# Install Maven
RUN apk add --no-cache maven

# Build the application
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:25-jre-alpine
WORKDIR /app

# Copy the built artifact
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
