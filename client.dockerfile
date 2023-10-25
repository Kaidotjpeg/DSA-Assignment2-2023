# Use the Ballerina base image
FROM ballerina/ballerina:swan-lake

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the client.bal file into the container
COPY Part1/client/client.bal .

# Command to run the Ballerina client
CMD ["ballerina", "run", "client.bal"]
