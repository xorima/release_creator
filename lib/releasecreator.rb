# frozen_string_literal: true

require 'sinatra'

require_relative 'releasecreator/semver'
require_relative 'releasecreator/vcs'
require_relative 'releasecreator/hmac'

get '/' do
  'Alive'
end

post '/handler' do
  return halt 500, "Signatures didn't match!" unless validate_request(request)

  payload = JSON.parse(params[:payload])
  case request.env['HTTP_X_GITHUB_EVENT']
  when 'pull_request'
    if target_default_branch?(payload) && merged_webhook?(payload)
      vcs = ReleaseCreator::Vcs.new(token: ENV['GITHUB_TOKEN'], pull_request: payload['pull_request'],
                                    repository: payload['repository'])
      semver = ReleaseCreator::SemVer.new(pull_request: payload['pull_request'])
      current_version = vcs.latest_semvar_release
      new_version = semver.increment_release(current_version)
      release_body = vcs.unreleased_changelog_entry
      vcs.create_changelog_entry(new_version)
      rel = vcs.create_release(new_version, release_body)
      vcs.add_release_comment("Released as: [#{new_version}](#{rel['html_url']})")
      rel['tag_name']
    end
  end
end

def validate_request(request)
  true unless ENV['SECRET_TOKEN']
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)
end

def merged_webhook?(payload)
  return true if payload['action'] == 'closed' && payload['pull_request']['merged']

  false
end

def target_default_branch?(payload)
  return true if payload['pull_request']['base']['ref'] == payload['repository']['default_branch']

  false
end
