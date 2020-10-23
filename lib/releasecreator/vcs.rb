# frozen_string_literal: true

require 'octokit'

module ReleaseCreator
  # Used to handle calls to VCS
  class Vcs
    def initialize(token:, pull_request:, repository:, changelog_name: 'CHANGELOG.md')
      @client = Octokit::Client.new(access_token: token)
      @repository = repository
      @pull_request = pull_request
      @repository_name = repository['full_name']
      @changelog_name = changelog_name
      @default_branch = repository['default_branch']
      @comment_base = 'This has been released as'
    end

    def latest_semvar_release
      git_tags = @client.tags(@repository_name)
      tag = git_tags.select { |t| t[:name] =~ /^\d+\.\d+\.\d+$/ }
      return tag[0]['name'] if tag[0]

      '0.0.0'
    end

    def unreleased_changelog_entry
      content = get_file_contents(@changelog_name)['content']
      result = /##\s+(Unreleased)([\s\S]*?)##/im.match(content)
      return result[2].strip if result

      nil
    end

    def create_changelog_entry(new_version)
      file = get_file_contents(@changelog_name)
      changelog_heading = "#{new_version} - *#{Time.now.strftime('%Y-%m-%d')}*"
      file['content'] = file['content'].gsub(/unreleased/i, changelog_heading)
      update_file_contents(@changelog_name, "Update changelog for #{new_version}", file['sha'], file['content'])
    end

    def create_release(new_version, release_body)
      @client.create_release(@repository_name, new_version, {
                               target_commitish: @default_branch,
                               name: new_version,
                               body: release_body
                             })
    end

    def add_release_comment(body)
      @client.add_comment(@repository_name,
                          @pull_request['number'],
                          body)
    end

    private

    def get_file_contents(file_path)
      file_content = @client.contents(@repository_name, path: file_path, ref: @default_branch)
      content = Base64.decode64(file_content[:content])
      response = {}
      response['content'] = content
      response['sha'] = file_content[:sha]
      response
    end

    def update_file_contents(file_path, commit_message, file_sha, file_content)
      begin
        @client.update_contents(@repository_name, file_path,
                                commit_message, file_sha, file_content, branch: @default_branch)
      rescue StandardError => e
        puts(e)
        return e
      end
      commit_message
    end
  end
end
