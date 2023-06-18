import ballerina/graphql;

graphql:Client testClient = check new("http://localhost:9090/graphql");
