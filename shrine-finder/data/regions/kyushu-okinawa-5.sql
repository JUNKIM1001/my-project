-- 九州・沖縄 追加データ (kyushu-okinawa-5) : 著名社寺の追加収録
-- 出典: ja.wikipedia.org infobox の十進座標で裏取り
-- 既存収録(_have_kyushu-okinawa.txt)・既存SQL(kyushu-okinawa, -2〜-4)とは重複させない

-- ===== batch 1 =====
-- 新規神仏: なし(既存神仏で充足: shaka_nyorai, senju_kannon, takeiwatatsu, amaterasu, haniyasuhime, takeminakata, susanoo, ukanomitama, ninigi, konohanasakuya)

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('nanzoin-sasaguri','南蔵院','なんぞういん','temple','高野山真言宗','福岡県','糟屋郡篠栗町','福岡県糟屋郡篠栗町篠栗1035',33.619750,130.572833,1899,'釈迦如来','https://nanzoin.net/','篠栗四国八十八ヶ所霊場の総本寺。全長41mの世界最大級の釈迦涅槃像で知られる。','https://ja.wikipedia.org/wiki/南蔵院_(福岡県篠栗町)','Wikipedia',true,now()),
('nomiyama-kannonji','呑山観音寺','のみやまかんのんじ','temple','高野山真言宗','福岡県','糟屋郡篠栗町','福岡県糟屋郡篠栗町萩尾227-4',33.658833,130.568083,null,'千手観音菩薩',null,'篠栗四国八十八ヶ所第16番札所。桜・紫陽花・紅葉の名所で「のみ山観音」と親しまれる。','https://ja.wikipedia.org/wiki/呑山観音寺','Wikipedia',true,now()),
('aburayama-kannon','油山観音（正覚寺）','あぶらやまかんのん','temple','臨済宗東福寺派','福岡県','福岡市','福岡県福岡市城南区東油山508',33.527306,130.369944,null,'千手観音菩薩',null,'天平年間に清賀上人が開いたと伝わる古刹。福岡市街を望む油山中腹の観音霊場。','https://ja.wikipedia.org/wiki/正覚寺_(福岡市)','Wikipedia',true,now()),
('rokuden-jinja','六殿神社','ろくでんじんじゃ','shrine','旧郷社','熊本県','熊本市','熊本県熊本市南区富合町木原2378',32.700667,130.708750,1178,null,null,'国宝級の楼門「釘無しの門」で知られる古社。阿蘇大明神ほか六柱を祀る。','https://ja.wikipedia.org/wiki/六殿神社','Wikipedia',true,now()),
('kibana-jinja','木花神社','きばなじんじゃ','shrine','旧郷社','宮崎県','宮崎市','宮崎県宮崎市熊野9508',31.827500,131.432222,null,null,null,'木花咲耶姫の出産の地と伝わる「無戸室」を境内に残す古社。日向神話ゆかりの社。','https://ja.wikipedia.org/wiki/木花神社','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='nanzoin-sasaguri' and d.slug in ('shaka_nyorai'))
or (t.slug='nomiyama-kannonji' and d.slug in ('senju_kannon'))
or (t.slug='aburayama-kannon' and d.slug in ('senju_kannon'))
or (t.slug='rokuden-jinja' and d.slug in ('takeiwatatsu','amaterasu'))
or (t.slug='kibana-jinja' and d.slug in ('ninigi','konohanasakuya'))
on conflict do nothing;

-- ===== batch 2 =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('fugen_bosatsu','普賢菩薩','ふげんぼさつ','buddha','菩薩','{}','仏教','釈迦三尊の脇侍。理・行・慈悲をつかさどる菩薩。','https://ja.wikipedia.org/wiki/普賢菩薩','Wikipedia',true,now()),
('minamoto_yoritomo','源頼朝','みなもとのよりとも','kami','人物神','{}','史実','鎌倉幕府初代将軍。武家政権を樹立した武将。','https://ja.wikipedia.org/wiki/源頼朝','Wikipedia',true,now()),
('saigo_takamori','西郷隆盛','さいごうたかもり','kami','人物神','{南洲}','史実','明治維新の元勲。西南戦争に倒れた薩摩の英傑。','https://ja.wikipedia.org/wiki/西郷隆盛','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='fugen_bosatsu' and g.slug in ('choju','kaiun','gakumon'))
or (d.slug='minamoto_yoritomo' and g.slug in ('shusse','shobu','kaiun'))
or (d.slug='saigo_takamori' and g.slug in ('shusse','shigoto','kaiun'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('enkakuji-naha','円覚寺','えんかくじ','temple','臨済宗妙心寺派','沖縄県','那覇市','沖縄県那覇市首里当蔵町',26.218330,127.719440,1492,'釈迦三尊（釈迦如来・文殊菩薩・普賢菩薩）',null,'琉球王国における臨済宗の総本山。第二尚氏の菩提寺。放生橋は国指定重要文化財。','https://ja.wikipedia.org/wiki/円覚寺_(那覇市)','Wikipedia',true,now()),
('hanao-jinja','花尾神社','はなおじんじゃ','shrine','旧県社','鹿児島県','鹿児島市','鹿児島県鹿児島市花尾町4043',31.706389,130.500944,1218,null,null,'絢爛な社殿から「薩摩日光」と称される。島津氏ゆかりで源頼朝らを祀る。','https://ja.wikipedia.org/wiki/花尾神社','Wikipedia',true,now()),
('nanshu-jinja-kagoshima','南洲神社','なんしゅうじんじゃ','shrine','旧県社相当','鹿児島県','鹿児島市','鹿児島県鹿児島市上竜尾町2',31.606472,130.558806,1922,null,null,'西郷隆盛と西南戦争の戦没者を祀る。隣接の南洲墓地・南洲翁顕彰館とともに参拝される。','https://ja.wikipedia.org/wiki/南洲神社','Wikipedia',true,now()),
('daikozenji-kiyama','大興善寺','だいこうぜんじ','temple','天台宗','佐賀県','三養基郡基山町','佐賀県三養基郡基山町園部3628',33.429167,130.496222,717,'十一面観音菩薩','https://daikouzenji.com/','「つつじ寺」として知られる古刹。背後の山に約5万本のつつじが咲く名所。','https://ja.wikipedia.org/wiki/大興善寺_(佐賀県基山町)','Wikipedia',true,now()),
('kotaiji-nagasaki','晧台寺','こうたいじ','temple','曹洞宗','長崎県','長崎市','長崎県長崎市寺町1-1',32.745560,129.882780,1608,'釈迦如来',null,'長崎三大寺の一つ。シーボルトの娘イネらの墓があり、大仏を安置する古刹。','https://ja.wikipedia.org/wiki/晧台寺','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='enkakuji-naha' and d.slug in ('shaka_nyorai','monju_bosatsu','fugen_bosatsu'))
or (t.slug='hanao-jinja' and d.slug in ('minamoto_yoritomo'))
or (t.slug='nanshu-jinja-kagoshima' and d.slug in ('saigo_takamori'))
or (t.slug='daikozenji-kiyama' and d.slug in ('juichimen_kannon'))
or (t.slug='kotaiji-nagasaki' and d.slug in ('shaka_nyorai'))
on conflict do nothing;

-- ===== batch 3 =====
insert into deity (slug, name, name_kana, kind, category, aliases, mythology_source, description, source_url, source_name, verified, verified_at) values
('hikoyai','日子八井命','ひこやいのみこと','kami','国津神','{彦八井耳命}','記紀','神武天皇の皇子。草部吉見神社の主祭神。','https://ja.wikipedia.org/wiki/草部吉見神社','Wikipedia',true,now()),
('hayamikatamao','速瓶玉命','はやみかたまのみこと','kami','国津神','{}','その他','健磐龍命の子。初代阿蘇国造とされ国造神社の主祭神。','https://ja.wikipedia.org/wiki/国造神社','Wikipedia',true,now()),
('takenouchi_sukune','武内宿禰','たけうちのすくね','kami','人物神','{武内宿禰命}','記紀','記紀に登場する大臣。長寿と忠臣の象徴とされる。','https://ja.wikipedia.org/wiki/武内宿禰','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into deity_goriyaku (deity_id, goriyaku_id)
select d.id, g.id from deity d join goriyaku g on true where
   (d.slug='hikoyai' and g.slug in ('kaiun','yakubarai','kanai_anzen'))
or (d.slug='hayamikatamao' and g.slug in ('suisan_noko','kaiun','kanai_anzen'))
or (d.slug='takenouchi_sukune' and g.slug in ('choju','shusse','kosodate'))
on conflict do nothing;

insert into temple_shrine
  (slug, name, name_kana, type, sect, prefecture, city, address, lat, lng, founded_year, honzon_note, website, description, source_url, source_name, verified, verified_at) values
('kusakabe-yoshimi-jinja','草部吉見神社','くさかべよしみじんじゃ','shrine','式内論社・旧県社','熊本県','阿蘇郡高森町','熊本県阿蘇郡高森町草部2175',32.782639,131.217972,null,null,null,'日本三大下り宮の一つ。鳥居より100段以上下った社殿が特徴。神武皇子日子八井命を祀る。','https://ja.wikipedia.org/wiki/草部吉見神社','Wikipedia',true,now()),
('kokuzo-jinja-aso','国造神社','こくぞうじんじゃ','shrine','式内社・旧県社','熊本県','阿蘇市','熊本県阿蘇市一の宮町手野2100',32.989611,131.124306,null,null,null,'阿蘇神社の北に鎮座する式内社。初代阿蘇国造・速瓶玉命を祀る古社。','https://ja.wikipedia.org/wiki/国造神社','Wikipedia',true,now()),
('goshinji-nagasaki','悟真寺','ごしんじ','temple','浄土宗','長崎県','長崎市','長崎県長崎市曙町6-14',32.752500,129.861940,1598,'阿弥陀三尊',null,'長崎市最古の現存寺院。唐人・オランダ・ロシア・稲佐の四国際墓地を擁する。','https://ja.wikipedia.org/wiki/悟真寺_(長崎市)','Wikipedia',true,now()),
('kaku-jinja-oita','賀来神社','かくじんじゃ','shrine','旧郷社','大分県','大分市','大分県大分市賀来58',33.206778,131.561694,836,null,null,'豊後の古社。武内宿禰命と健磐龍命を祀り、賀来の市(秋祭り)で知られる。','https://ja.wikipedia.org/wiki/賀来神社','Wikipedia',true,now()),
('kaidanin-dazaifu','戒壇院','かいだんいん','temple','臨済宗','福岡県','太宰府市','福岡県太宰府市観世音寺5-7-10',33.514783,130.520828,753,'盧舎那仏',null,'鑑真開創と伝わる日本三戒壇の一つ。西海道唯一の授戒の道場であった古刹。','https://ja.wikipedia.org/wiki/戒壇院','Wikipedia',true,now())
on conflict (slug) do nothing;

insert into temple_shrine_deity (temple_shrine_id, deity_id, role)
select t.id, d.id, 'main' from temple_shrine t join deity d on true where
   (t.slug='kusakabe-yoshimi-jinja' and d.slug in ('hikoyai'))
or (t.slug='kokuzo-jinja-aso' and d.slug in ('hayamikatamao'))
or (t.slug='goshinji-nagasaki' and d.slug in ('amida_nyorai'))
or (t.slug='kaku-jinja-oita' and d.slug in ('takenouchi_sukune','takeiwatatsu'))
or (t.slug='kaidanin-dazaifu' and d.slug in ('rushana_butsu'))
on conflict do nothing;
