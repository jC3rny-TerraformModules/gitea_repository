
# gitea_org
variable "gitea_org_name" {
  type = string
  #
  default = ""
}

# gitea_repository
variable "gitea_repository" {
  type = map(object({
    name = optional(string)
    #
    private = optional(bool)
    #
    description = optional(string)
    license     = optional(string)
    #
    auto_init      = optional(bool)
    default_branch = optional(string)
    #
    repo_template = optional(bool)
    #
    has_wiki = optional(bool)
    #
    has_issues = optional(bool)
    #
    has_projects = optional(bool)
    #
    has_pull_requests = optional(bool)
    #
    allow_manual_merge    = optional(bool)
    allow_merge_commits   = optional(bool)
    allow_rebase          = optional(bool)
    allow_rebase_explicit = optional(bool)
    allow_squash_merge    = optional(bool)
    #
    autodetect_manual_merge     = optional(bool)
    ignore_whitespace_conflicts = optional(bool)
    #
    archived = optional(bool)
  }))
  #
  default = {}
}

# gitea_team
variable "gitea_default_teams_membership" {
  type = object({
    Readers = optional(list(string))
    #
    Writers = optional(list(string))
    #
    Admins = optional(list(string))
  })
  #
  default = {
    Readers = []
    Writers = []
    Admins  = []
  }
}
