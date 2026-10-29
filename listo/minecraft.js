const categories = [
  ['all','Все'],['license','Лицензия'],['items','Предметы'],['keys','Ключи'],
  ['capes','Плащи'],['codes','Коды'],['resources','Ресурс-паки'],
  ['configs','Конфиги'],['other','Прочее'],['guides','Гайды'],['donate','Донат']
];
const raw = window.location.search.replace(/^\?/, '').split('&')[0].split('=')[0].toLowerCase();
const active = categories.some(([id]) => id === raw) ? raw : 'all';
const label = categories.find(([id]) => id === active)[1];
document.getElementById('category-title').textContent = active === 'all' ? 'Все объявления' : label;
document.title = `${label} — Minecraft — listo`;
document.getElementById('filters').innerHTML = categories.map(([id, title]) =>
  `<a href="minecraft.html${id === 'all' ? '' : '?' + id}" ${id === active ? 'class="active" aria-current="page"' : ''}>${title}</a>`
).join('');
