# The GitHub User
#
# + name - User name  
# + login - Logged in user
# + id - User id  
# + bio - User bio  
# + url - Prfile url 
# + created_at - Created date of Profile  
# + updated_at - Last update date
# + avatar_url - Avatar url  
# + 'type - User type  
# + company - User company  
# + blog - User blog  
# + location - User location  
# + email - User email 
# + public_repos - number if public repos  
# + followers - Number if followers  
# + following - Number of following
type User record {
  string name;
  string login;
  int id;
  string bio;
  string url;
  string created_at;
  string updated_at;
  string avatar_url;
  string 'type;
  string? company;
  string blog;
  string? location;
  string? email?;
  int public_repos?;
  int followers?;
  int following?;
};

# The Repository Branch
#
# + id - Branch id  
# + name - Branch name
# + prefix - Branch prefix
public type Branch record {
    string id;
    string name;
    string prefix;
};

# The GitHub Repository
#
# + id - Repository id  
# + name - The name of the repository.  
# + description - The description of the repository.  
# + 'fork - Field Description  
# + created_at - Identifies the date and time when the object was created.  
# + updated_at - Identifies the date and time when the object was last updated.  
# + language - The language composition of the repository.  
# + owner - The owner of the repository.  
# + has_issues - State whether there are issues or not  
# + forks_count - Fork count  
# + open_issues_count - Open issues count  
# + lisense - License type  
# + allow_forking - State wether forking is allowed or not  
# + visibility - Visibility of the repository  
# + forks - Number of forks  
# + open_issues - Number of open issues  
# + watchers - Number of watchers  
# + default_branch - Name of the default branch
public type Repository record {
    int id;
    string name;
    string? description;
    boolean 'fork;
    string created_at;
    string updated_at;
    string? language;
    Owner owner?;
    boolean has_issues;
    int forks_count;
    int open_issues_count;
    License lisense?;
    boolean allow_forking;
    string visibility;
    int forks;
    int open_issues;
    int watchers;
    string default_branch;
};

# The Repository Owner
#
# + login - Logged in user  
# + id - user id  
# + url - Profile url  
# + 'type - User type
public type Owner record {
    string login;
    int id;
    string url;
    string 'type;
};

# The GitHub Repository Lisence
#
# + key - Lisence key  
# + name - Lisen name
public type License record {
    string key;
    string name;
};
