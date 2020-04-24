require 'date'
require 'json'

require 'restclient'

require_relative 'get_versions_from_ref.rb'

marketing_version, build_version, beta, semantic_version = get_versions_from_ref(ENV['GIT_REF']).values_at(:marketing_version, :build_version, :beta, :semantic_version)

base_url = 'https://api.github.com/repos/dimitarnestorov/MusicBar/git/'
auth = "token #{ENV['GITHUB_TOKEN']}"

headers_get = { authorization: auth }
headers_post = { authorization: auth, content_type: 'application/json' }

last_commit_sha = JSON.parse(RestClient.get("#{base_url}refs/heads/update", headers_get).body)['object']['sha']

last_tree_sha = JSON.parse(RestClient.get("#{base_url}commits/#{last_commit_sha}", headers_get).body)['tree']['sha']

def content(build_version, semantic_version)
    return %{\{
    "currentRelease": "#{build_version}",
    "releases": \[
        \{
            "version": "#{build_version}",
            "updateTo": \{
                "version": "#{build_version}",
                "pub_date": "#{DateTime.now.iso8601}",
                "notes": "No notes",
                "name": "#{build_version}",
                "url": "https://github.com/dimitarnestorov/MusicBar/releases/download/#{semantic_version}/MusicBar.zip"
            \}
        \}
    \]
\}
}
end

if beta
    new_tree = [{
        path: "beta-#{marketing_version}.json",
        mode: "100644",
        type: "blob",
        content: content(build_version, semantic_version),
    }]
else
    last_tree = JSON.parse(RestClient.get("#{base_url}trees/#{last_tree_sha}", headers_get).body)['tree']
    new_tree = [{
        path: "stable.json",
        mode: "100644",
        type: "blob",
        content: content(build_version, semantic_version),
    }]
    last_tree.each do |item|
        if item['path'] == "beta-#{marketing_version}.json" && item['mode'] == "100644"
            new_tree.push({
                path: item['path'],
                mode: "120000",
                type: "blob",
                content: "stable.json",
            })
        end
    end
end

payload = { base_tree: last_tree_sha, tree: new_tree }
new_tree_sha = JSON.parse(RestClient.post("#{base_url}trees", payload.to_json, headers_post).body)['sha']

payload = { message: semantic_version, parents: [ last_commit_sha ], tree: new_tree_sha }
new_commit_sha = JSON.parse(RestClient.post("#{base_url}commits", payload.to_json, headers_post).body)['sha']

payload = { sha: new_commit_sha }
puts RestClient.post "#{base_url}refs/heads/update", payload.to_json, headers_post
