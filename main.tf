
locals {
  gitea_repository = {
    for k, v in var.gitea_repository : k => {
      name     = coalesce(v.name, k)
      username = data.gitea_org.this.name
      #
      private = coalesce(v.private, true)
      #
      description = try(v.description, "")
      license     = coalesce(v.license, "MIT")
      #
      auto_init      = coalesce(v.auto_init, true)
      default_branch = coalesce(v.default_branch, "main")
      #
      repo_template = coalesce(v.repo_template, false)
      #
      has_wiki = coalesce(v.has_wiki, true)
      #
      has_issues = coalesce(v.has_issues, true)
      #
      has_projects = coalesce(v.has_projects, true)
      #
      has_pull_requests = coalesce(v.has_pull_requests, true)
      #
      allow_manual_merge    = coalesce(v.allow_manual_merge, false)
      allow_merge_commits   = coalesce(v.allow_merge_commits, true)
      allow_rebase          = coalesce(v.allow_rebase, true)
      allow_rebase_explicit = coalesce(v.allow_rebase_explicit, true)
      allow_squash_merge    = coalesce(v.allow_squash_merge, true)
      #
      autodetect_manual_merge     = coalesce(v.autodetect_manual_merge, false)
      ignore_whitespace_conflicts = coalesce(v.ignore_whitespace_conflicts, false)
      #
      archived = coalesce(v.auto_init, false)
    }
  }
  #
  gitea_default_users = { for k, v in distinct(flatten([for obj in var.gitea_default_teams_membership : obj if obj != null])) : v => {} }
  #
  gitea_default_teams_membership = {
    # for k, v in var.gitea_default_teams_membership : format("%s-%s-%s", lower(data.gitea_org.this.name), "default", k) => {
    for k, v in var.gitea_default_teams_membership : lower(k) => {
      name        = k
      description = format("%s org. %s %s", data.gitea_org.this.name, "default", lower(k))
      #
      permission = (k == "Admins" ? "admin" : (k == "Writers" ? "write" : "read"))
      #
      members = [for obj in coalesce(v, []) : data.gitea_user.default[obj].username]
    }
  }
}


data "gitea_org" "this" {
  name = var.gitea_org_name
}


resource "gitea_repository" "repository" {
  for_each = { for k, v in local.gitea_repository : k => v }
  #
  name     = each.value.name
  username = each.value.username
  #
  private = each.value.private
  #
  description = each.value.description
  license     = each.value.license
  #
  auto_init      = each.value.auto_init
  default_branch = each.value.default_branch
  #
  repo_template = each.value.repo_template
  #
  has_wiki = each.value.has_wiki
  #
  has_issues = each.value.has_issues
  #
  has_projects = each.value.has_projects
  #
  has_pull_requests = each.value.has_pull_requests
  #
  allow_manual_merge    = each.value.allow_manual_merge
  allow_merge_commits   = each.value.allow_merge_commits
  allow_rebase          = each.value.allow_rebase
  allow_rebase_explicit = each.value.allow_rebase_explicit
  allow_squash_merge    = each.value.allow_squash_merge
  #
  autodetect_manual_merge     = each.value.autodetect_manual_merge
  ignore_whitespace_conflicts = each.value.ignore_whitespace_conflicts
  #
  archived = each.value.archived
  #
  depends_on = [
    data.gitea_org.this
  ]
}


data "gitea_user" "default" {
  for_each = local.gitea_default_users
  #
  username = each.key
  #
  depends_on = [
    data.gitea_org.this
  ]
}

resource "gitea_team" "default" {
  for_each = { for k, v in local.gitea_default_teams_membership : k => v }
  #
  name        = each.value.name
  description = each.value.description
  #
  organisation = data.gitea_org.this.name
  #
  include_all_repositories = true
  can_create_repos = false
  #
  permission = each.value.permission
  #
  members = each.value.members
  #
  depends_on = [
    data.gitea_org.this,
    data.gitea_user.default
  ]
}
