# frozen_string_literal: true

require 'spec_helper'

describe ReleaseCreator::SemVer do
  it 'Increments a Patch correctly' do
    pr = { 'labels' => [{ 'name' => 'Release: Patch' }] }
    client = ReleaseCreator::SemVer.new({ pull_request: pr })
    expect(client.increment_release('1.2.3')).to eq '1.2.4'
  end
  it 'Increments a Minor correctly' do
    pr = { 'labels' => [{ 'name' => 'Release: Minor' }] }
    client = ReleaseCreator::SemVer.new({ pull_request: pr })
    expect(client.increment_release('1.2.3')).to eq '1.3.0'
  end
  it 'Increments a Patch correctly' do
    pr = { 'labels' => [{ 'name' => 'Release: Major' }] }
    client = ReleaseCreator::SemVer.new({ pull_request: pr })
    expect(client.increment_release('1.2.3')).to eq '2.0.0'
  end
end
