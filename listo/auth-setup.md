# Настройка входа listo

## Никнейм и пароль

На текущем статическом GitHub Pages сайте вход по никнейму реализован через внутренний email-идентификатор вида `nickname@accounts.li.do4me.art`, не видимый пользователю. Это прототипный способ поверх Supabase Email Auth, **не полноценный username auth backend**. Настоящая почта не собирается, поэтому восстановление пароля недоступно. Для регистрации нужно отключить **Confirm email** в Supabase → Authentication → Providers → Email. **Перед публичным запуском рекомендуется заменить этот способ отдельным серверным username-auth**, чтобы обеспечить проверку уникальности, защиту от перебора и безопасное восстановление доступа.

## Google OAuth

Supabase → Authentication → Providers → Google: включить Google и указать Client ID / Client Secret из Google Cloud. В Google Cloud разрешить callback `https://pkvwdzaceksdmqwxesbf.supabase.co/auth/v1/callback`. В Supabase → Authentication → URL Configuration добавить в Redirect URLs `https://ruze-developer.github.io/ruze-ms/account.html` и `https://li.do4me.art/account.html` (если домен указывает на тот же сайт).

## Объявления

Если при продаже написано `Could not find the table 'public.listings' in the schema cache`, таблица ещё не создана. Выполните `supabase-schema.sql` в SQL Editor **проекта pkvwdzaceksdmqwxesbf**, не в базе Ruze. После этого обновите страницу. При необходимости в Supabase проверьте Data API и доступ схемы public.
