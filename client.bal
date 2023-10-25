import ballerina/graphql;
import ballerina/io;

public function main() returns error? {
    // Define the GraphQL client to interact with the service
    graphql:Client graphqlClient = check new ("http://localhost:9000/graphql");

    // Define a GraphQL query to fetch department objectives
    string departmentObjectivesQuery = "query {
        getDepartmentObjectives(departmentId: 1) {
            departmentObjectiveID
            departmentName
            objectiveDescription
            departmentGoalPercentage
        }
    }";;

    // Fetch department objectives using the defined query
    var departmentObjectivesResponse = check graphqlClient->execute(departmentObjectivesQuery);
    checkForErrors(departmentObjectivesResponse);

    // Print the department objectives
    io:println("Department Objectives:");
    foreach var departmentObjective in departmentObjectivesResponse.getArray("getDepartmentObjectives") {
        io:println(departmentObjective.toString());
    }

    // Define a GraphQL query to fetch KPIs for an employee
    string kpisQuery = "query {
        getKPIs(employeeId: 1) {
            kpiID
            description
            unit
            departmentObjectiveID
            departmentID
            weight
            maxScore
        }
    }";

    // Fetch KPIs for an employee using the defined query
    var kpisResponse = check graphqlClient->execute(kpisQuery);
    checkForErrors(kpisResponse);

    // Print the KPIs
    io:println("KPIs:");
    foreach var kpi in kpisResponse.getArray("getKPIs") {
        io:println(kpi.toString());
    }

    // Define a GraphQL query to fetch an employee
    string employeeQuery = "query {
        getEmployee(employeeId: 1) {
            employeeID
            firstName
            lastName
            jobTitle
            position
            role
            departmentID
            supervisorID
            departmentObjectiveID
        }
    }";

    // Fetch an employee using the defined query
    var employeeResponse = check graphqlClient->execute(employeeQuery);
    checkForErrors(employeeResponse);

    // Print the employee details
    io:println("Employee:");
    io:println(employeeResponse.get("getEmployee").toString());

    // Define a GraphQL query to fetch supervisor details
    string supervisorQuery = "query {
        getSupervisor(employeeId: 1) {
            employeeID
            firstName
            lastName
            jobTitle
            position
            role
            departmentID
            supervisorID
            departmentObjectiveID
        }
    }";

    // Fetch supervisor details using the defined query
    var supervisorResponse = check graphqlClient->execute(supervisorQuery);
    checkForErrors(supervisorResponse);

    // Print the supervisor details
    io:println("Supervisor:");
    io:println(supervisorResponse.get("getSupervisor").toString());

    // Define a GraphQL query to calculate the total score for an employee
    string totalScoreQuery = "query {
        calculateEmployeeTotalScore(employeeId: 1)
    }";

    // Calculate the total score for an employee using the defined query
    var totalScoreResponse = check graphqlClient->execute(totalScoreQuery);
    checkForErrors(totalScoreResponse);

    // Print the total score
    io:println("Total Score:");
    io:println(totalScoreResponse.toString());

    // Define a GraphQL query to view an employee's KPI scores
    string viewScoresQuery = "query {
        viewEmployeeScores(employeeId: 1) {
            kpiID
            score
        }
    }";

    // View an employee's KPI scores using the defined query
    var viewScoresResponse = check graphqlClient->execute(viewScoresQuery);
    checkForErrors(viewScoresResponse);

    // Print the KPI scores
    io:println("Employee's KPI Scores:");
    foreach var kpiScore in viewScoresResponse.getArray("viewEmployeeScores") {
        io:println(kpiScore.toString());
    }

    // You can similarly define and execute other queries or mutations

    // Handle errors if any
    if (employeeResponse.hasErrors()) {
        // Handle GraphQL errors
        io:println("GraphQL Errors:");
        foreach var err in employeeResponse.getErrors() {
            io:println(err.toString());
        }
    }

    // Close the GraphQL client
    graphqlClient->close();
}

function checkForErrors(graphqlResponse graphql:Response) {
    // Check for errors in the GraphQL response
    if (graphqlResponse.hasErrors()) {
        // Handle GraphQL errors
        io:println("GraphQL Errors:");
        foreach var err in graphqlResponse.getErrors() {
            io:println(err.toString());
        }
        check graphqlResponse.close();
        error("GraphQL response contains errors");
    }
}
