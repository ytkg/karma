# frozen_string_literal: true

require_relative '../../../lib/kaiteki/comment_builder'

describe Kaiteki::CommentBuilder do
  describe '#build' do
    subject(:build) do
      described_class.new(
        reason: reason,
        feeling_temperature: feeling_temperature,
        new_set_temperature: new_set_temperature
      ).build
    end

    let(:feeling_temperature) { 25.5 }
    let(:new_set_temperature) { 24 }

    context '理由が :lowered の場合' do
      let(:reason) { :lowered }
      it '温度を下げた旨のコメントを返す' do
        expect(build).to eq "体感温度が25.5°だったので、エアコンの設定温度を24°に変更しました"
      end
    end

    context '理由が :raised の場合' do
      let(:reason) { :raised }
      it '温度を上げた旨のコメントを返す' do
        expect(build).to eq "体感温度が25.5°だったので、エアコンの設定温度を24°に変更しました"
      end
    end

    context '理由が :in_range の場合' do
      let(:reason) { :in_range }
      it '温度を変更しなかった旨のコメントを返す' do
        expect(build).to eq "体感温度が25.5°で目標範囲内のため、エアコンの設定温度は変更しませんでした"
      end
    end

    context '理由が :improving_trend の場合' do
      let(:reason) { :improving_trend }
      it '温度を変更しなかった旨のコメントを返す' do
        expect(build).to eq "体感温度が25.5°で改善傾向のため、エアコンの設定温度は変更しませんでした"
      end
    end

    context '理由が :at_min_limit の場合' do
      let(:reason) { :at_min_limit }
      it '下限に達した旨のコメントを返す' do
        expect(build).to eq "設定温度が下限のため、エアコンの設定温度は変更しませんでした"
      end
    end

    context '理由が :at_max_limit の場合' do
      let(:reason) { :at_max_limit }
      it '上限に達した旨のコメントを返す' do
        expect(build).to eq "設定温度が上限のため、エアコンの設定温度は変更しませんでした"
      end
    end
  end
end
