# $skipped is a JSON array of issue numbers, passed via --argjson skipped '[...]'
def recent(days): (now - (days*86400)) | todate;

[.data.repository.issues.nodes[] | {
  number, title, url, updatedAt,
  comments: .comments.totalCount,
  assignees: [.assignees.nodes[].login],
  labels: [.labels.nodes[].name],
  linkedPRs: [.timelineItems.nodes[]
    | select(.__typename == "CrossReferencedEvent" and .source.__typename == "PullRequest")
    | {n: .source.number, state: .source.state, draft: .source.isDraft,
       merged: .source.merged, updatedAt: .source.updatedAt, author: .source.author.login}]
}
| select(
    ([.number] | inside($skipped) | not)
    and (.assignees | length) == 0
    and ([.linkedPRs[] | select(.state == "OPEN")] | length) == 0
    and ([.linkedPRs[] | select(.state == "CLOSED" and .merged == false and .updatedAt > recent(30))] | length) == 0
    and ([.labels[] | select(. == "blocked" or . == "wontfix" or . == "duplicate" or . == "invalid")] | length) == 0
  )
]
