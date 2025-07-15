# Stage 1: Build the application
FROM maven:3.8.5-eclipse-temurin-17 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Run the application
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY --from=builder /app/target/CompanyDashBoard-0.0.1-SNAPSHOT.war app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
