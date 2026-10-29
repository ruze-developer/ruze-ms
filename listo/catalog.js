const catalogs={
 minecraft:[['all','Все'],['license','Лицензия'],['items','Предметы'],['keys','Ключи'],['capes','Плащи'],['codes','Коды'],['resources','Ресурс-паки'],['configs','Конфиги'],['other','Прочее'],['guides','Гайды'],['donate','Донат']],
 telegram:[['all','Все'],['premium','Premium'],['stars','Звёзды'],['gifts','Подарки'],['channels','Каналы'],['bots','Боты'],['other','Прочее']],
 roblox:[['all','Все'],['robux','Robux'],['items','Предметы'],['accounts','Аккаунты'],['gamepasses','Геймпассы'],['services','Услуги'],['other','Прочее']]
};
const slug=document.body.dataset.catalog||'minecraft';
const categories=catalogs[slug];
const raw=window.location.search.replace(/^\?/,'').split('&')[0].split('=')[0].toLowerCase();
const active=categories.some(([id])=>id===raw)?raw:'all';
const label=categories.find(([id])=>id===active)[1];
document.getElementById('category-title').textContent=active==='all'?'Все объявления':label;
document.title=label+' — '+slug+' — listo';
const nav=document.getElementById('filters');
for(const [id,title] of categories){const a=document.createElement('a');a.href=slug+'.html'+(id==='all'?'':'?'+id);a.textContent=title;if(id===active){a.className='active';a.setAttribute('aria-current','page')}nav.append(a)}
