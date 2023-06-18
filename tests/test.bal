import ballerina/test;

@test:Config {
    groups: ["query"],
    enable: true
}
function testUser() returns error? {
    string query = "query { user { name } }";
    json expectedResult = {
        "data": {
            "user": {
                "name": owner
            }
        }
    };
    json actualResult = check testClient->execute(query);
    test:assertEquals(expectedResult, actualResult, "Invalid user name");
}

@test:Config {
    groups: ["query"],
    enable: true
}
function testRepositories() returns error? {
    string query = "query { repositories { owner { login } } }";
    json jsonResponse = check testClient->execute(query);
    test:assertTrue(jsonResponse is map<json>, "Invalid response type");
    map<json> actualResult = check jsonResponse.ensureType();
    test:assertTrue(actualResult.hasKey("data"));
    test:assertFalse(actualResult.hasKey("errors"));
}

@test:Config {
    groups: ["query"],
    enable: false
}
function testRepository() returns error? {
    string repoName = "";
    string query = string `query { repository(repositoryName: "${repoName}"){ owner{ login } } }`;
    json expectedResult = {
        "data": {
            "repository": {
                "owner": {
                    "login": owner
                }
            }
        }
    };
    json actualResult = check testClient->execute(query);
    test:assertEquals(expectedResult, actualResult);
}

@test:Config {
    groups: ["query"],
    enable: false
}
function testBranches() returns error? {
    string repoName = "ballerina-lang";
    string query = string `query { branches(repositoryName: "${repoName}"){ name } }`;
    json expectedResult = {
        "data": {
            "branches": [
                {
                    "name": "master"
                }
            ]
        }
    };
    json actualResult = check testClient->execute(query);
    test:assertEquals(expectedResult, actualResult);
}

@test:Config {
    groups: ["mutation"],
    enable: false
}
function createRepository() returns error? {
    string repoName = "test-repo";
    string query = string `mutation {createRepository(createRepoInput: {name: "${repoName}", visibility: PRIVATE_REPOSITORY}) {name} }`;
    json expectedResult = {
        "data": {
            "createRepository": {
                "name": repoName
            }
        }
    };
    json actualResult = check testClient->execute(query);
    test:assertEquals(expectedResult, actualResult);
}

