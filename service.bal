import ballerina/graphql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
import ballerina/sql;

public type DepartmentObjective record {|
    int departmentObjectiveID;
    string departmentName;
    string objectiveDescription;
    float departmentGoalPercentage;
|};

public type KeyPerformanceIndicator record {|
    int kpiID;
    string description;
    string unit;
    int departmentObjectiveID;
    int departmentID;
    float weight;
    float maxScore;
|};

public type Employee record {|
    int employeeID;
    string firstName;
    string lastName;
    string jobTitle;
    string position;
    string role;
    int departmentID;
    int supervisorID;
    int departmentObjectiveID;
|};

public type EmployeeKPIScore record {|
    int employeeID;
    int kpiID;
    decimal score;
|};

final mysql:Client dbClient = check new(
    host="localhost", user="rootUser", password="rootPass", port="3306", database="yourdatabasename" 
); // That is the actual name of the database

service on new graphql:Listener(9000) {

    resource function get getDepartmentObjectives(int departmentId) returns DepartmentObjective[] {
    // Fetch department objectives based on the departmentID
    DepartmentObjective[] departmentObjectives = fetchDepartmentObjectives(departmentId);
    return departmentObjectives;
    }

    resource function get getKPIs(int employeeId) returns KeyPerformanceIndicator[] {
    // Fetch KPIs for the specified employee
    KeyPerformanceIndicator[] kpis = fetchKPIsForEmployee(employeeId);
    return kpis;
    }

    resource function get getEmployee(int employeeId) returns Employee|error {
    // Fetch employee details based on the employeeID
    Employee|error employee = fetchEmployeeDetails(employeeId);
    return employee;
    }

    resource function get getSupervisor(int employeeId) returns Employee|error {
    // Fetch the supervisor of the specified employee
    Employee|error supervisor = fetchSupervisor(employeeId);
    return supervisor;
    }

    resource function get calculateEmployeeTotalScore(int employeeId) returns float|error {
    // Calculate the total score of the specified employee
    // Fetch the employee's KPIs, calculate the weighted average, and return the score
    float|error totalScore = calculateTotalScoreForEmployee(employeeId);
    return totalScore;
    }

    resource function get viewEmployeeScores(int employeeId) returns KeyPerformanceIndicator[] {
    // Fetch and return an employee's KPI scores
    KeyPerformanceIndicator[] kpiScores = fetchKpiScoresForEmployee(employeeId);
    return kpiScores;
    }

    resource function get getEmployeeKPIs(int employeeId) returns KeyPerformanceIndicator[] {
    // Fetch KPIs for the specified employee
    KeyPerformanceIndicator[] kpis = fetchKPIsForEmployee(employeeId);
    return kpis;
    }

    remote function createDepartmentObjective(
    string departmentName,
    string objectiveDescription,
    float departmentGoalPercentage
    ) returns DepartmentObjective|error {
        // Create a new department objective
        // Insert a new DepartmentObjective record into the data source and return the created object
        DepartmentObjective|error departmentObjective = createNewDepartmentObjective(departmentName, objectiveDescription, departmentGoalPercentage);
        return departmentObjective;
    }

    remote function deleteDepartmentObjective(int departmentObjectiveID) returns boolean|error {
    // Delete the department objective based on departmentObjectiveID
    // Return a boolean indicating whether the deletion was successful
    boolean|error isDeleted = deleteDepartmentObjectiveByID(departmentObjectiveID);
    return isDeleted;
    }

    remote function createKPI(
    string description,
    string unit,
    int departmentObjectiveID,
    int departmentID,
    float weight,
    float maxScore
    ) returns KeyPerformanceIndicator|error {
        // Create a new KPI
        // Insert a new KeyPerformanceIndicator record into the database and return the created object
        KeyPerformanceIndicator|error kpi = createNewKPI(description, unit, departmentObjectiveID, departmentID, weight, maxScore);
        return kpi;
    }

    remote function assignEmployeeToSupervisor(int employeeID, int supervisorID) returns boolean|error {
    // Assign an employee to a supervisor
    // Update the employee record with the supervisor ID
    boolean|error isAssigned = assignEmployeeToSupervisorByID(employeeID, supervisorID);
    return isAssigned;
    }

    remote function createEmployee(
    string firstName,
    string lastName,
    string jobTitle,
    string position,
    string role,
    int departmentID,
    int departmentObjectiveID,
    int supervisorID
    ) returns Employee|error {
        // Create a new employee
        // Insert a new Employee record into the database and return the created object
        Employee|error employee = createNewEmployee(firstName, lastName, jobTitle, position, role, departmentID, departmentObjectiveID, supervisorID);
        return employee;
    }

    remote function gradeSupervisor(int employeeID, float score) returns boolean|error {
    // Grade a supervisor's performance
    // Update the supervisor's performance score in the database
    boolean|error isGraded = gradeSupervisorPerformance(employeeID, score);
    return isGraded;
    }

    remote function gradeKPI(int kpiID, float score) returns boolean|error {
    // Grade a specific KPI
    // Update the KPI score in the database
    boolean|error isGraded = gradeKPIPerformance(kpiID, score);
    return isGraded;
    }

    remote function createEmployeeKPI(
    int employeeID,
    string description,
    string unit,
    int departmentObjectiveID,
    int departmentID,
    float weight,
    float maxScore
    ) returns KeyPerformanceIndicator|error {
        // Create a new employee KPI
        // Insert a new KeyPerformanceIndicator record into the database and return the created object
        KeyPerformanceIndicator|error kpi = createNewEmployeeKPI(employeeID, description, unit, departmentObjectiveID, departmentID, weight, maxScore);
        return kpi;
    }
}

function createNewEmployeeKPI(int employeeID, string description, string unit, int departmentObjectiveID, int departmentID, float weight, float maxScore) returns KeyPerformanceIndicator|error {
    // Define a SQL query to insert a new EmployeeKPI with parameter placeholders
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO EmployeeKPIs (employeeID, description, unit, departmentObjectiveID, departmentID, weight, maxScore)
        VALUES (${employeeID}, ${description}, ${unit}, ${departmentObjectiveID}, ${departmentID}, ${weight}, ${maxScore})`;

    // Execute the SQL insert query
    sql:Result|sql:Error insertResult = check dbClient->execute(insertQuery);

    // Check if the insert operation was successful
    if (insertResult is sql:Result) {
        // Retrieve the auto-generated kpiID of the inserted record
        int kpiID = <int>insertResult.lastInsertId;

        // Create a KeyPerformanceIndicator object with the inserted values
        KeyPerformanceIndicator newKPI = {
            kpiID: kpiID,
            description: description,
            unit: unit,
            departmentObjectiveID: departmentObjectiveID,
            departmentID: departmentID,
            weight: weight,
            maxScore: maxScore
        };

        // Return the newly created KeyPerformanceIndicator
        return newKPI;
    } else {
        // Return an error if the insert operation failed
        return error("Failed to create a new EmployeeKPI");
    }
}

function gradeKPIPerformance(int score, float kpiID) returns boolean|error {
    // Define a SQL query to update the score of a KPI
    sql:ParameterizedQuery updateQuery = `
        UPDATE EmployeeKPIs
        SET score = ${score}
        WHERE kpiID = ${kpiID}`;

    // Execute the SQL update query
    sql:Result|sql:Error updateResult = check dbClient->execute(updateQuery);

    // Check if the update operation was successful
    if (updateResult is sql:Result) {
        // Check if any rows were affected by the update (indicating a successful grading)
        int affectedRows = updateResult.affectedRowCount;
        if (affectedRows == 1) {
            // KPI performance successfully graded
            return true;
        } else {
            // No rows affected (no KPI with the specified ID found)
            return false;
        }
    } else {
        // Return an error if the update operation failed
        return error("Failed to grade the KPI performance");
    }
}

function gradeSupervisorPerformance(int i, float f) returns boolean {
    return false;
}

function createNewEmployee(string firstName, string lastName, string jobTitle, string position, string role, int departmentID, int supervisorID, int departmentObjectiveID) returns Employee|error{
    // Define a SQL query to insert a new employee with parameter placeholders
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO Employees (firstName, lastName, jobTitle, position, role, departmentID, supervisorID, departmentObjectiveID)
        VALUES (${firstName}, ${lastName}, ${jobTitle}, ${position}, ${role}, ${departmentID}, ${supervisorID}, ${departmentObjectiveID})`;

    // Execute the SQL insert query
    sql:Result|sql:Error insertResult = check dbClient->execute(insertQuery);

    // Check if the insert operation was successful
    if (insertResult is sql:Result) {
        // Retrieve the auto-generated employeeID of the inserted record
        int employeeID = <int>insertResult.lastInsertId;

        // Create an Employee object with the inserted values
        Employee newEmployee = {
            employeeID: employeeID,
            firstName: firstName,
            lastName: lastName,
            jobTitle: jobTitle,
            position: position,
            role: role,
            departmentID: departmentID,
            supervisorID: supervisorID,
            departmentObjectiveID: departmentObjectiveID
        };

        // Return the newly created Employee
        return newEmployee;
    } else {
        // Return an error if the insert operation failed
        return error("Failed to create a new employee");
    }
}

function assignEmployeeToSupervisorByID(int supervisorID, int employeeID) returns boolean|error {
    // Define a SQL query to update the supervisor ID of an employee
    sql:ParameterizedQuery updateQuery = `
        UPDATE Employees
        SET supervisorID = ${supervisorID}
        WHERE employeeID = ${employeeID}`;

    // Execute the SQL update query
    sql:Result|sql:Error updateResult = check dbClient->execute(updateQuery);

    // Check if the update operation was successful
    if (updateResult is sql:Result) {
        // Check if any rows were affected by the update (indicating a successful assignment)
        int affectedRows = updateResult.affectedRowCount;
        if (affectedRows == 1) {
            // Employee successfully assigned to the supervisor
            return true;
        } else {
            // No rows affected (no employee with the specified ID found)
            return false;
        }
    } else {
        // Return an error if the update operation failed
        return error("Failed to assign the employee to the supervisor");
    }
}

function createNewKPI(string description, string unit, int departmentObjectiveID, int departmentID, float weight, float maxScore) returns KeyPerformanceIndicator|error {
    // Define a SQL query to insert a new KPI with parameter placeholders
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO KeyPerformanceIndicators (description, unit, departmentObjectiveID, departmentID, weight, maxScore)
        VALUES (${description}, ${unit}, ${departmentObjectiveID}, ${departmentID}, ${weight}, ${maxScore})`;

    // Execute the SQL insert query
    sql:Result|sql:Error insertResult = check dbClient->execute(insertQuery);

    // Check if the insert operation was successful
    if (insertResult is sql:Result) {
        // Retrieve the auto-generated kpiID of the inserted record
        int kpiID = <int>insertResult.lastInsertId;

        // Create a KeyPerformanceIndicator object with the inserted values
        KeyPerformanceIndicator newKPI = {
            kpiID: kpiID,
            description: description,
            unit: unit,
            departmentObjectiveID: departmentObjectiveID,
            departmentID: departmentID,
            weight: weight,
            maxScore: maxScore
        };

        // Return the newly created KeyPerformanceIndicator
        return newKPI;
    } else {
        // Return an error if the insert operation failed
        return error("Failed to create a new KPI");
    }
}

function deleteDepartmentObjectiveByID(int i) returns boolean|error {
    // Define a SQL query to delete a department objective by its ID
    sql:ParameterizedQuery deleteQuery = `
        DELETE FROM DepartmentObjectives
        WHERE departmentObjectiveID = ${departmentObjectiveID}`;

    // Execute the SQL delete query
    sql:Result|sql:Error deleteResult = check dbClient->execute(deleteQuery);

    // Check if the delete operation was successful
    if (deleteResult is sql:Result) {
        // Check if any rows were affected by the delete (indicating a successful deletion)
        int affectedRows = deleteResult.affectedRowCount;
        if (affectedRows > 0) {
            // Department objective successfully deleted
            return true;
        } else {
            // No rows affected (no department objective with the specified ID found)
            return false;
        }
    } else {
        // Return an error if the delete operation failed
        return error("Failed to delete the department objective");
    }
}

function createNewDepartmentObjective(string departmentName, string objectiveDescription, float departmentGoalPercentage) returns DepartmentObjective|error {
    // Define a SQL query to insert a new department objective with parameter placeholders
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO DepartmentObjectives (departmentName, objectiveDescription, departmentGoalPercentage)
        VALUES (${departmentName}, ${objectiveDescription}, ${departmentGoalPercentage})`;

    // Execute the SQL insert query
    sql:Result|sql:Error insertResult = check dbClient->execute(insertQuery);

    // Check if the insert operation was successful
    if (insertResult is sql:Result) {
        // Retrieve the auto-generated departmentObjectiveID of the inserted record
        int departmentObjectiveID = <int>insertResult.lastInsertId;

        // Create a DepartmentObjective object with the inserted values
        DepartmentObjective newObjective = {
            departmentObjectiveID: departmentObjectiveID,
            departmentName: departmentName,
            objectiveDescription: objectiveDescription,
            departmentGoalPercentage: departmentGoalPercentage
        };

        // Return the newly created DepartmentObjective
        return newObjective;
    } else {
        // Return an error if the insert operation failed
        return error("Failed to create a new department objective");
    }
}

function fetchKpiScoresForEmployee(int i) returns KeyPerformanceIndicator[] {
    // Define a SQL query to retrieve KPI scores for the specified employee
    sql:ParameterizedQuery query = `
        SELECT kpiID, score
        FROM KpiScores
        WHERE employee_id = ?`;
    
    // Execute the SQL query and retrieve the results
    table<KeyPerformanceIndicator> result = check dbClient->query(query, employeeId);

    // Initialize an empty array to store KeyPerformanceIndicator objects
    KeyPerformanceIndicator[] kpiScoresArray = [];

    // Iterate through each row in the query result
    foreach var row in result.records {
        // Create a KeyPerformanceIndicator object for each row
        KeyPerformanceIndicator kpiScore = {
            kpiID: <int>row["kpiID"],
            score: <float>row["score"]
        };

        // Add the KeyPerformanceIndicator object to the array
        kpiScoresArray.push(kpiScore);
    }

    // Return the array of KPI scores as the result
    return kpiScoresArray;
}

function calculateTotalScoreForEmployee(int employeeId) returns float|error {
    // Retrieve the KPIs assigned to the employee and their scores
    sql:ParameterizedQuery kpiQuery = `SELECT kpiID, weight
        FROM kpis
        WHERE departmentID = (SELECT departmentID FROM employees WHERE employeeID = ?)`;
    table<record { int kpiID; decimal weight }> result = check dbClient->query(kpiQuery, employeeId);

    // Calculate the weighted average based on KPI weights
    float totalScore = 0.0;
    float totalWeight = 0.0;
    foreach var row in result.records {
        totalScore += row.weight;
        totalWeight += row.weight;
    }

    if (totalWeight > 0.0) {
        return totalScore / totalWeight;
    } else {
        return 0.0; // Handle division by zero or missing records
    }
}

function fetchSupervisor(int employeeId) returns Employee|error {
    // Define a SQL query to retrieve the supervisor for the specified employee
    sql:ParameterizedQuery query = `SELECT * FROM Employees WHERE supervisor_id = ?`;

    // Execute the SQL query and retrieve the results
    table<Employee> result = check dbClient->query(query, employeeId);

    // Check if a single supervisor was found
    if (result.length() == 1) {
        return result[0];
    } else {
        return error("Supervisor not found");
}

function fetchEmployeeDetails(int employeeId) returns Employee|error {
    // Define a SQL query to retrieve employee details for the specified employee
    sql:ParameterizedQuery query = `SELECT * FROM Employees WHERE employee_id = ?`;

    // Execute the SQL query and retrieve the results
    table<Employee> result = check dbClient->query(query, employeeId);

    // Check if a single employee was found
    if (result.length() == 1) {
        return result[0];
    } else {
        return error("Employee not found");
}

function fetchKPIsForEmployee(int employeeId) returns KeyPerformanceIndicator[] {
    // Define a SQL query to retrieve KPIs for the specified employee
    sql:ParameterizedQuery query = `SELECT * FROM KeyPerfomanceObjectives WHERE employee_id = ?`;
    
    // Execute the SQL query and retrieve the results
    table<KeyPerformanceIndicator> result = check dbClient->query(query, employeeId);

    // Initialize an empty array to store KPI objects
    KeyPerformanceIndicator[] kpiArray = [];

    // Iterate through each row in the query result
    foreach var row in result.records {
        // Create a KeyPerformanceIndicator object for each row
        KeyPerformanceIndicator kpi = {
            kpiID: <int>row["kpiID"],
            description: <string>row["description"],
            unit: <string>row["unit"],
            departmentObjectiveID: <int>row["departmentObjectiveID"],
            departmentID: <int>row["departmentID"],
            weight: <float>row["weight"],
            maxScore: <float>row["maxScore"]
        };

        // Add the KPI object to the array
        kpiArray.push(kpi);
    }

    // Return the array of KPI objects as the result
    return kpiArray;
}

function fetchDepartmentObjectives(int departmentId) returns DepartmentObjective[] {
    // Define a SQL query to retrieve department objectives for the specified department
    sql:ParameterizedQuery query = `SELECT * FROM DepartmentObjectives WHERE department_id = ?`;

    // Execute the SQL query and retrieve the results
    table<DepartmentObjective> result = check dbClient->query(query, departmentId);

    // Initialize an empty array to store DepartmentObjective objects
    DepartmentObjective[] objectivesArray = [];

    // Iterate through each row in the query result
    foreach var row in result.records {
        // Create a DepartmentObjective object for each row
        DepartmentObjective objective = {
            departmentObjectiveID: <int>row["departmentObjectiveID"],
            departmentName: <string>row["departmentName"],
            objectiveDescription: <string>row["objectiveDescription"],
            departmentGoalPercentage: <float>row["departmentGoalPercentage"]
        };

        // Add the DepartmentObjective object to the array
        objectivesArray.push(objective);
    }

    // Return the array of DepartmentObjective objects as the result
    return objectivesArray;
}
