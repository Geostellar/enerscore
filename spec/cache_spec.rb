require 'spec_helper'

RSpec.describe Enerscore::Api do
    let(:cache) { Enerscore::Cache.new cache_store, prefix }
    let(:prefix) { nil }
    let(:cache_store) { Redis.new }
    let(:key) { 'test_key' }
    let(:value) { { "test_object" => 'test', "another" => 'test2' } }

  describe '#initialize' do
    subject { cache }

    context 'when the cache store is nil' do
      let(:cache_store) { nil }
      it 'raises an error' do
        expect{ subject }.to raise_error 'Cache store cannot be nil'
      end
    end

    context 'when the cache store is present' do
      it 'stores the cache_store' do
        expect(subject.instance_variable_get(:@cache_store)).to eq cache_store
      end

      context 'when a prefix is present' do
        let(:prefix) { 'new_prefix' }
        it 'stores the prefix' do
          expect(subject.instance_variable_get(:@prefix)).to eq prefix
        end
      end
    end
  end

  describe '#cache_key' do
    subject { cache.send :cache_key, key }
    context 'when a prefix is present' do
      let(:prefix) { 'new_prefix::' }
      it { is_expected.to eq 'enerscore::new_prefix::test_key' }
    end

    context 'when a prefix is not present' do
      it { is_expected.to eq 'enerscore::test_key' }
    end
  end

  describe '#clear_cache' do
    subject { cache.clear_cache }
    it 'clears the cache for the enerscore namespace' do
      cache_store.set cache.send(:namespace), 'test'
      cache_store.set "#{cache.send(:namespace)}_test", 'test_2'
      expect(cache_store.keys.count).to eq 2
      subject
      expect(cache_store.keys).to be_empty
    end

    it 'does not clear keys outside of the name space' do
      cache_store.set 'outside_name_space', 'two'
      cache_store.set cache.send(:namespace), 'test'
      subject
      key = cache_store.keys[0]
      expect(cache_store.get(key)).to eq 'two'
    end

    context 'when no enerscore keys are present' do
    it 'does not clear keys outside of the name space' do
      cache_store.set 'outside_name_space', 'two'
      subject
      expect(cache_store.keys.count).to eq 1
      key = cache_store.keys[0]
      expect(cache_store.get(key)).to eq 'two'
    end

      it 'does not throw an error' do
        expect{ subject }.to_not raise_error
      end
    end
  end

  describe '#namespace' do
    subject { cache.send :namespace }
    it { is_expected.to eq 'enerscore::' }
  end

  describe '#read' do
    subject { cache.read key }
    let(:key) { 'test_key' }
    context 'when a value is present' do
      before { cache_store.set cache.send(:cache_key, key), value.to_json }
      let(:value) { { "test_object" => 'test', "another" => 'test2' } }
      it { is_expected.to eq value }
    end

    context 'when a vaule is not present' do
      it { is_expected.to be_nil }
    end
  end

  describe '#write' do
    subject { cache.write key, value }

    it 'writes the value to the cache as a json string' do
      subject
      cache_key = cache_store.keys[0]
      expect(cache_store.get(cache_key)).to eq value.to_json
    end
  end

  describe '#delete' do
    subject { cache.delete key }

    context 'when the value is present' do
    before { cache_store.set cache.send(:cache_key, key), value.to_json }
    it { is_expected.to eq true }
    end

    context 'when the value is not present' do
      it { is_expected.to eq false }
    end
  end
end
