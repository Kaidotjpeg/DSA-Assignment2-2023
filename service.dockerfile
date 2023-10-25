# Use the Ballerina base image
FROM ballerina/ballerina:swan-lake

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the service.bal file into the container
COPY Part1/service/service.bal .

# Expose the required port for the service
EXPOSE 9000

# Command to run the Ballerina service
CMD ["ballerina", "run", "service.bal"]
