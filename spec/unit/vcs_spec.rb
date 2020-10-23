# frozen_string_literal: true

require 'spec_helper'

describe ReleaseCreator::Vcs, :vcr do
  # Check Vcs creates an OctoKit client
  before(:each) do
    @client = ReleaseCreator::Vcs.new({
                                        token: ENV['GITHUB_TOKEN'] || 'temp_token',
                                        pull_request: {'number' => 30},
                                        repository: {
                                          'full_name' => 'Xorima/xor_test_cookbook', 'default_branch' => 'master'
                                        }
                                      })
  end

  it 'creates an octkit client' do
    expect(@client).to be_kind_of(ReleaseCreator::Vcs)
  end

  it 'returns the latest semver git tag' do
    tag = @client.latest_semvar_release
    expect(tag).to eq '0.20.1'
  end

  it 'returns the unreleased section from the changelog' do
    expect(@client.unreleased_changelog_entry).to eq "- Added 'Testing stuff'"
  end

  it 'updates the changelog as expected' do
    expect(@client.create_changelog_entry('1.2.3')).to eq 'Update changelog for 1.2.3'
  end

  it 'creates a release' do
    body = '- this is my body'
    version = '1.2.3'
    release = @client.create_release(version, body)
    expect(release['tag_name']).to eq version
    expect(release['body']).to eq body
  end

  it 'comments on the closed pr with the release number' do
    body = 'This is my comment'
    comment = @client.add_release_comment(body)
    expect(comment['body']).to eq body
  end
end
