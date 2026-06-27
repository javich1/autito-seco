# Autito Seco — Guía para publicar como app

## Qué vas a lograr
Tu app funcionando como una app real instalable en el celular (iOS y Android),
accesible desde un link que compartís con tus amigos. Gratis, sin App Store.

---

## Paso 1 — Crear cuenta en Netlify (gratis, 2 minutos)

1. Entrá a https://netlify.com
2. Clic en "Sign up" → elegí "Email" o "GitHub"
3. Completá el registro → ya estás adentro

---

## Paso 2 — Subir la app

**Opción A — Arrastrar y soltar (más fácil):**
1. En el dashboard de Netlify, abajo dice:
   *"Want to deploy a new site without connecting to Git? Drag and drop your site output folder here"*
2. Arrastrá la carpeta `autito-seco` completa ahí
3. Netlify la sube en segundos y te da una URL tipo:
   `https://nombre-random-123.netlify.app`

**Opción B — Desde GitHub (recomendado si querés actualizar fácil):**
1. Creá cuenta en https://github.com (si no tenés)
2. Creá un repositorio nuevo, subí los archivos de la carpeta `autito-seco`
3. En Netlify → "Add new site" → "Import from Git" → conectás el repo
4. Cada vez que actualices los archivos en GitHub, Netlify actualiza la app solo

---

## Paso 3 — URL personalizada (opcional, gratis)

Netlify te deja cambiar el subdominio gratis:
- En tu site → Site settings → Domain management → "Change site name"
- Podés ponerle algo como `autito-seco.netlify.app`

---

## Paso 4 — Instalar en el celular

**En Android (Chrome):**
1. Abrí la URL en Chrome
2. Arriba a la derecha → los tres puntos → "Añadir a pantalla de inicio"
3. Le ponés el nombre → "Agregar"
4. Ya aparece como app en tu escritorio

**En iPhone (Safari):**
1. Abrí la URL en Safari (importante: tiene que ser Safari, no Chrome)
2. Toca el botón de compartir (el cuadrado con flechita hacia arriba)
3. Bajá hasta "Añadir a pantalla de inicio"
4. Le ponés el nombre → "Agregar"
5. Ya está instalada con el ícono verde

---

## Paso 5 — Compartir con tus amigos

Mandales el link de Netlify. Cada uno:
- Abre el link en su celular
- Lo instala como app siguiendo el Paso 4
- Sus datos se guardan en SU celular (independiente de los demás)

---

## Archivos de la carpeta autito-seco

```
autito-seco/
├── index.html      ← La app completa
├── manifest.json   ← Config de la PWA (nombre, colores, íconos)
├── sw.js           ← Service Worker (funciona offline)
├── icon-192.png    ← Ícono para Android / home screen
└── icon-512.png    ← Ícono grande (splash screen)
```

---

## ¿Cuánto cuesta?

**Nada.** El plan gratuito de Netlify incluye:
- 100GB de ancho de banda por mes
- Deploys ilimitados
- HTTPS incluido
- Más que suficiente para vos y tus amigos

---

## ¿Los datos se comparten entre usuarios?

No. Cada persona tiene sus propios datos guardados en su celular (localStorage).
Si querés que los datos se sincronicen entre dispositivos del mismo usuario
(por ejemplo, ver desde el celu y la compu), eso requeriría una base de datos
en la nube — lo podemos agregar más adelante con Supabase (también gratis para uso básico).

---

## Soporte

Si algo no funciona, revisá que:
- La carpeta que subís a Netlify se llame `autito-seco` y tenga los 5 archivos
- En iPhone siempre instalar desde Safari (no desde Chrome ni otro browser)
- La URL empieza con `https://` (Netlify lo hace automáticamente)
