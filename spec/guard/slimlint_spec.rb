require 'spec_helper'
require 'guard/compat/test/helper'
require 'guard/slimlint'
require 'colorize'

RSpec.describe Guard::SlimLint do
  subject { described_class.new(notifications: false) }
  before { File.delete("#{@core}/Guardfile") if File.exist?("#{@core}/Guardfile") }
  before { system('bundle exec guard init') }
  after { File.delete("#{@core}/Guardfile") if File.exist?("#{@core}/Guardfile") }

  describe 'initialization guard' do
    let(:core_guardfile_content) { File.read(@core_guardfile) }
    let(:lib_guardfile_content) { File.read(@lib_guardfile) }

    context 'when Guardfile does not exists' do
      it { expect(File.exist?("#{@core}/Guardfile")).to be true }
      it { expect(core_guardfile_content).to include(lib_guardfile_content) }
    end

    context 'when Guardfile already exists' do
      before { system('bundle exec guard init') }
      it { expect(core_guardfile_content).to include(lib_guardfile_content) }
    end
  end

  describe 'run guard' do
    context 'when some offences are found' do
      let(:message) { 'Slim offences detected' }
      it do
        expect(Guard::UI).to receive(:info).with("Inspecting Slim code style: #{@failfile}")
        expect(Guard::UI).to receive(:info).with('There are Slim offences ^^^'.red)
        expect(Guard::Notifier).to receive(:notify).with(message, title: 'Slim-lint results', image: :failed)
        subject.run_on_modifications(@failfile)
      end
    end

    context 'when no offences found' do
      it do
        expect(Guard::UI).to receive(:info).with("Inspecting Slim code style: #{@testfile}")
        expect(Guard::UI).to receive(:info).with('No Slim offences detected'.green)
        subject.run_on_modifications(@testfile)
      end
    end
  end
end
