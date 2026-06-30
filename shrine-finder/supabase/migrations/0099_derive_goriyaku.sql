-- 全社寺のご利益を御祭神/本尊から一括導出（地域データ投入後に実行・冪等）
insert into temple_shrine_goriyaku (temple_shrine_id, goriyaku_id)
select distinct tsd.temple_shrine_id, dg.goriyaku_id
from temple_shrine_deity tsd
join deity_goriyaku dg on dg.deity_id = tsd.deity_id
on conflict do nothing;
