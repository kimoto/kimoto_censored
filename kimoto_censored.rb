# -*- encoding: utf-8 -*-
$KCODE='utf-8'
require 'MeCab'
require 'rubygems'
require File.dirname(__FILE__) + '/roma2kana'

class KimotoCensored
  private
  DEFAULT_MEISI_DICT_PATH = File.dirname(__FILE__) + "/dic/meisi.txt"
  DEFAULT_YOUGEN_DICT_PATH = File.dirname(__FILE__) + "/dic/yougen.txt" 

  def abbrev_name(name)
    name.split('').first 
  end

  def make_positive_dictionary(yougen_dict, meisi_dict)
    dict_ary=[]

    File.read(meisi_dict).split("\n").each{ |line|
      elements = line.split(' ')

      # 先頭と末尾に"があれば除去
      elements[0] = elements[0].tr('"', '')
      
      dict_ary << elements
    }

    File.read(yougen_dict).split("\n").each{ |line|
      elements = line.split("\t")

      if elements[0] =~ /^ポジ/
        elements[0] = 'p'
      elsif elements[0] =~ /^ネガ/ 
        elements[0] = 'n'
      else
        elements[0] = 'e'
      end

      tmp = elements[0]
      elements[0] = elements[1]
      elements[1] = tmp

      dict_ary << elements
    }
    dict_ary
  end

  # 指定されたキーワードを分類し、n/p/eのどれかを返却する
  # n = negative
  # p = positive
  # e = equal
  def positive_classify(name)
    @dict.each{ |elements|
      if elements[0] == name
        return elements[1]
      end
    }
    return 'e'
  end

  def positive_classify_sentence(dict, sentence)
    node = @mecab.parseToNode(sentence)

    n = p = e = 0
    while node
      r = positive_classify(node.surface)
      p += 1 if r == 'p'
      n += 1 if r == 'n'
      e += 1 if e == 'e'
      node = node.next
    end 

    [n,p,e]
  end

  public
  def initialize(yougen_dict = DEFAULT_YOUGEN_DICT_PATH, meisi_dict = DEFAULT_MEISI_DICT_PATH)
    @dict = make_positive_dictionary(yougen_dict, meisi_dict)
    @mecab = MeCab::Tagger.new
  end

  # 問題点1: 意味が反転されてるときにそれを意識してポジティブ要素を反転できてない
  def is_negative_sentence(sentence)
    (n,p,e) = positive_classify_sentence(@dict, sentence)
    (n > p)
  end

  def is_positive_sentence(sentence)
    !is_negative_sentence(sentence)
  end

  def kimoto_censored(str, ng_words = [])
    node = @mecab.parseToNode(str)

    result = []
    while node
      #puts "#{node.surface}\t#{node.feature}" for debug
      if node.feature =~ /^名詞,固有名詞/
        unless (orig_name = node.feature.split(',').last) != '*'  # オリジナルの名前
          orig_name = node.surface
        end

        roma_name = orig_name.to_roma
        result << abbrev_name(roma_name).upcase # 簡略表記に変換
      else
        result << node.surface
      end

      node = node.next
    end
    r = result.join('')

    ng_words.each{ |word|
      r.gsub!(word, '<censored>')
    }

    r
  end
end

# string bind = omoi
class String
  def kimoto_censored
    KimotoCensored.new.kimoto_censored(self)
  end

  def is_negative
    KimotoCensored.new.is_negative_sentence(self)
  end

  def is_positive
    KimotoCensored.new.is_positive_sentence(self)
  end
end

if $0 == __FILE__
  p "死ぬ".is_negative
  p "死ぬ".is_positive
  p "kimotoが、googleのサーバーを破壊した".kimoto_censored
end

