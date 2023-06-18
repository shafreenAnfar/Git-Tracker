import ballerina/graphql;
import ballerina/http;
import ballerina/io;
import ballerinax/github;
import xlibb/pubsub;

configurable string authToken = ?;
configurable string owner = ?;

@graphql:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    },
    graphiql: {
        enabled: true
    }
}
service /graphql on new graphql:Listener(9090) {

    final github:Client githubConnector;
    final http:Client githubRestClient;
    final http:Client githubGraphqlClient;

    private final pubsub:PubSub pubsub = new;

    function init() returns error? {
        self.githubConnector = check new ({auth: {token: authToken}});
        self.githubRestClient = check new ("https://api.github.com", {auth: {token: authToken}});
        self.githubGraphqlClient = check new ("https://api.github.com/graphql", {auth: {token: authToken}});
        io:println(string `💃 Server ready at http://localhost:9090/graphql`);
        io:println(string `Access the GraphiQL UI at http://localhost:9090/graphiql`);
    }

    # Get GitHub User Details
    # 
    # + return - GitHub repository list
    resource function get user() returns User|error {
        User user = check self.githubRestClient->get(string `/user`);
        return user;
    }

    # Get GitHub Repository List
    # 
    # + return - GitHub repository list
    resource function get repositories() returns Repository[]|error {
        Repository[] repositories = check self.githubRestClient->get(string `/users/${owner}/repos`);
        return repositories;
    }

    # Get Repository
    #
    # + repositoryName - Repository name
    # + return - GitHub repository
    resource function get repository(string repositoryName) returns github:Repository|error {
        github:Repository repository = check self.githubConnector->getRepository(owner, repositoryName);
        return repository;
    }

    # Get Branches
    #
    # + repositoryName - Repository name
    # + return - Repository branches
    resource function get branches(string repositoryName) returns github:Branch[]|error {
        string stringQuery = check getGraphqlQueryFromFile("queries");
        json variables = {
            username: owner,
            repositoryName: repositoryName, 
            perPageCount: 100,
            lastPageCursor: null
        };
        return getBranches(self.githubGraphqlClient, stringQuery, variables);
    }

    # Create Repository
    #
    # + createRepoInput - Represent create repository input payload
    # + return - GitHub repositor or error.
    remote function createRepository(github:CreateRepositoryInput createRepoInput) returns github:Repository|error {
        check self.githubConnector->createRepository(createRepoInput);
        github:Repository repository = check self.githubConnector->getRepository(owner, createRepoInput.name);
        return repository;
    }

    # Create Issue
    #
    # + createIssueInput - Create issue input payload  
    # + repositoryName - Repository name
    # + return - GitHub issue
    remote function createIssue(github:CreateIssueInput createIssueInput, string repositoryName) returns github:Issue|error {
        github:Issue issue = check self.githubConnector->createIssue(createIssueInput, owner, repositoryName);
        string topic = string `reviews-${repositoryName}`;
        check self.pubsub.publish(topic, issue.cloneReadOnly(), timeout = 5);
        return issue;
    }

    # Update Issue
    #
    # + updateIssueInput - Update issue input payload 
    # + repositoryName - Repository name 
    # + issueNumber - Issue number
    # + return - GitHub issue
    isolated remote function updateIssue(github:UpdateIssueInput updateIssueInput, string repositoryName, int issueNumber) returns github:Issue|error {
        github:Issue updatedIssue = check self.githubConnector->updateIssue(updateIssueInput, owner, repositoryName, issueNumber);
        return updatedIssue;
    }

    # Add Issue Comment
    #
    # + addIssueCommentInput - Add issue comment input payload
    # + return - Issue comment
    remote function addComment(github:AddIssueCommentInput addIssueCommentInput) returns github:IssueComment|error {
        github:IssueComment issueComment = check self.githubConnector->addComment(addIssueCommentInput);
        return issueComment;
    }

    # Update Issue Comment
    #
    # + updateCommentInput - Update issue comment input payload
    # + return - Success message
    remote function updateComment(github:UpdateIssueCommentInput updateCommentInput) returns string|error {
        check self.githubConnector->updateComment(updateCommentInput);
        return "Successfully updated the comment";
    }

    # Subscribe to issues created
    #
    # + repositoryName - Repository name
    # + return - Stream of issues
    resource function subscribe issueCreated(string repositoryName) returns stream<github:Issue, error?>|error {
        string topic = string `reviews-${repositoryName}`;
        return self.pubsub.subscribe(topic, timeout = -1);
    }
}
