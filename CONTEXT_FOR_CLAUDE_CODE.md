# Autito Seco — Contexto completo para Claude Code

## Qué es
PWA mobile-first para mantenimiento de vehículos. "El historial clínico de tu auto."
Una sola carpeta, sin bundler, sin backend. Todo en un HTML.

---

## Stack
- React 18 via CDN + Babel standalone (sin npm, sin bundler)
- Un solo archivo: `index.html` (~1150 líneas)
- Persistencia: `localStorage` (key: `autito_v1`)
- PWA: `manifest.json` + `sw.js` (offline cache)
- Deploy: Netlify (drag & drop de la carpeta)

---

## Shape del estado global

```js
{
  user: { email, name },
  vehicles: [
    {
      id: number,
      brand, model, year, plate, km, color,
      addedDate: ISOString,
      maints: [ ...copiaDeMAINTS_DEFAULT ]
    }
  ],
  favoriteVehicleId: number,  // auto que aparece en dashboard
  docs: [{ id, name, type, date, addedAt }],
  hist: [{ mid, vid, km, date, product }],
  workshop: [{ id, vid, date, place, person, phone, description, result, cost, createdAt }],
  dashView: 'grid' | 'list'
}
```

---

## MAINTS_DEFAULT — estructura de cada ítem

```js
{
  id: number,
  name: string,
  cat: 'monthly' | 'service',
  iconId: string,          // clave del objeto ICONS para SVG
  iKm: number | null,      // intervalo en km
  iDays: number | null,    // intervalo en días
  trigger: 'both' | 'km' | 'time',
  lastKm: null,
  lastDate: null,
  lastProduct: '',         // marca/producto usado en la última revisión
  desc: string,
  tip: string
}
```

Los 9 ítems con sus iconIds:
| id | name | cat | iconId | iKm | iDays | trigger |
|----|------|-----|--------|-----|-------|---------|
| 1 | Cubiertas | monthly | tire | null | 30 | time |
| 2 | Refrigerante | monthly | temp | null | 30 | time |
| 3 | Cambio de aceite | service | oil | 10000 | 365 | both |
| 4 | Filtro de aire | service | airflt | 15000 | 365 | both |
| 5 | Filtro de aceite | service | oilflt | 10000 | 365 | both |
| 6 | Filtro combustible | service | fuel | 30000 | 730 | both |
| 7 | Líquido de frenos | service | brake | null | 730 | time |
| 8 | Bujías | service | spark | 30000 | 730 | both |
| 9 | Correa distribución | service | belt | 80000 | 1825 | both |

---

## Lógica de salud de cada ítem

```js
const getStatus = (m, currentKm) => {
  // sin registro
  if (!m.lastDate) return { color:'blue', label:'Sin registro', pct:0, health:0, ... registered:false }

  const days = daysSince(m.lastDate)
  let pctTime = m.iDays ? Math.min(days / m.iDays, 1) : 0
  let pctKm   = (m.iKm && m.lastKm != null && currentKm != null)
    ? Math.min(Math.max(currentKm - m.lastKm, 0) / m.iKm, 1) : 0

  // wear = desgaste (0=nuevo, 1=vencido)
  const wear = trigger==='time' ? pctTime : trigger==='km' ? pctKm : Math.max(pctTime, pctKm)

  // health = lo que se muestra en la barra
  // 100% = recién revisado, 0% = vencido
  const health = 1 - wear

  // colores por wear
  if (wear >= 1)   → red,   'Urgente'
  if (wear >= 0.8) → red,   'Vencido pronto'
  if (wear >= 0.6) → amber, 'Próximo'
  else             → green, 'Al día'
}
```

---

## Acciones del reducer

```
LOGIN           { user }
ADD_VEH         { v }           → genera id:Date.now(), maints:copia de MAINTS_DEFAULT, setea favoriteVehicleId si es el primero
SET_FAV         { id }
UPD_KM          { vid, km }
APPLY           { vid, mid, km, date, product }  → actualiza lastKm/lastDate/lastProduct en maint + push a hist[]
TOGGLE_CAT      { vid, mid }    → alterna cat entre 'monthly' y 'service'
UPD_MAINT_INTERVAL { vid, mid, changes: { iKm, iDays, trigger } }
ADD_DOC         { doc }
DEL_DOC         { id }
ADD_WORK        { entry }       → entry incluye vid del vehículo activo
UPD_WORK        { entry }
DEL_WORK        { id }
SET_DASH_VIEW   { view }        → 'grid' | 'list'
RESET           {}
```

---

## Pantallas y navegación

Nav bottom fijo: **Inicio · Taller · Historial · Docs · Perfil**

### Login
- Decorativo — acepta cualquier email/pass, sin validación real
- **PENDIENTE:** conectar backend real (Supabase sugerido)

### VehicleForm (reutilizable)
- Setup inicial + agregar autos
- Campos: brand, model, year, plate, km, color
- Color picker: 16 colores con hex predefinidos
- El SVG del auto hace preview en tiempo real con el color elegido

### Dashboard
- Header: nombre del auto, patente, año, badge estado general, CarSVG con color del auto
- Si hay >1 auto: botón "Cambiar auto ↕" → modal selector
- Chip km actual + botón "Actualizar" → modal
- Toggle Lista/Grilla (grid 2col por defecto)
- Secciones: "Controles mensuales" y "Mantenimiento"

### MaintDetail
- Ícono SVG grande centrado
- Barra de salud grande (health %)
- Grid 2x2 con stats: último mant., días desde rev., km en revisión, km restantes
- Si hay lastProduct → chip "Último producto usado"
- Tip técnico en card verde dim
- Formulario de registro:
  - Fecha (date picker, max=hoy, acepta fechas pasadas)
  - KM (pre-llenado con km actual del vehículo)
  - Si km ingresado > km actual → banner amber con botón "Actualizar odómetro"
  - Campo "Marca / Producto utilizado" (opcional, se guarda en lastProduct)
  - Botón "Confirmar revisión"
- Link discreto "Mover a Mantenimiento / Controles mensuales"

### Workshop (Taller)
- Filtrado por `vid` del vehículo activo
- Entradas legacy sin `vid` se muestran en todos
- CRUD completo: lista → detalle → editar / eliminar
- Campos: fecha, lugar/taller, persona/mecánico, teléfono (clickeable para llamar), descripción*, resultado, costo
- Costo se formatea como `$XX.XXX` si es número
- **NO tiene campo de marcas/productos** (ese campo está en MaintDetail)

### History
- Filtrado por `vid` del vehículo activo
- Muestra: ícono + nombre del ítem, fecha, km

### Documents
- Tipos: VTV, Seguro, Cédula, Factura, Otro
- Campos: tipo, descripción, fecha vencimiento
- Alertas automáticas: borde rojo si vencido, amber si vence en <30 días

### Profile
- Avatar + nombre + email del usuario
- Lista de vehículos → click en cualquiera → VehicleDetailScreen
- ⭐ marca el favorito (el que aparece en dashboard)
- Opciones con chevron: "Personalizar intervalos" → IntervalsScreen, "Preguntas frecuentes" → FAQScreen
- Botón cerrar sesión (RESET)

### VehicleDetailScreen
- Datos completos del auto (marca, modelo, año, patente, km, color con muestra)
- Campo actualizar km
- Badge estado general
- Botón "Ir al dashboard con este auto" → SET_FAV + navega a home

### IntervalsScreen
- Lista de todos los maints del vehículo favorito
- Cada uno expandible para editar: iKm, iDays, trigger (El primero / Solo KM / Solo días)
- Badge "CUSTOM" si fue modificado vs default
- Muestra valores default como referencia

### FAQScreen
- Acordeón con 10 preguntas sobre cómo funciona la app
- Se expande/colapsa con tap

---

## Sistema de diseño

### Tipografía
- UI: `DM Sans` (Google Fonts, weights 300–800)
- Datos numéricos: `Space Mono` (km, %, patente)

### Paleta completa
```css
--bg-0: #060A07
--bg-1: #0B110C
--bg-2: #101814   ← cards
--bg-3: #162018   ← inputs, chips
--bg-4: #1C281E
--bg-5: #223025

--text-1: #EFF5F0
--text-2: #94A896
--text-3: #4D6450

--green:     #2EC864   ← acento principal / ok
--green-400: #4AE880
--green-600: #1FA84E
--green-dim: #0A2010
--green-mid: #122818

--amber:     #E8C84A   ← próximo / warn
--amber-dim: #201800

--red:       #E85A4A   ← urgente / error
--red-dim:   #200A08

--blue:      #4A9AE8   ← sin registro / info
--blue-dim:  #081428

--accent:     #2EC864
--accent-dim: #0A2010

--border:       rgba(46,200,100,0.10)
--border-hover: rgba(46,200,100,0.22)

--radius-sm: 10px
--radius-md: 14px
--radius-lg: 20px
--radius-xl: 28px
```

### Botones
```
primary   → bg #2EC864, color #060A07 (texto oscuro sobre verde)
secondary → bg var(--bg-3), color text-1, border
ghost     → bg transparent, color text-2, border
danger    → bg red-dim, color red
success   → bg green-dim, color green
```

### Sistema de íconos SVG
Objeto `ICONS` con ~25 íconos de línea (estilo Feather Icons), todos `stroke="currentColor"`, `strokeWidth="1.8"`.
Componente: `<Icon id="tire" size={20} color="var(--green)"/>`

IDs disponibles: `tire, temp, oil, airflt, oilflt, fuel, brake, spark, belt, wrench, car, doc, shield, card, receipt, clip, home, hist, folder, user, tag, phone, edit, trash, plus, check, chevR, chevD, back, star, starO, faq, gear, logout, warn, km`

---

## Componentes principales

```
<Login />
<VehicleForm onComplete={v => dispatch({type:'ADD_VEH',v})} onCancel={...} />
<Dashboard state vehicle vehicles dispatch onNav />
<MaintDetail m vehicle onApply(date,km,product) onBack onToggleCat dispatch />
<Workshop state dispatch vehicle />
  └── <WorkshopForm initial title onSave onCancel />   ← DEBE estar fuera de Workshop
                                                          para evitar re-mount en cada keystroke
<History state vehicle />
<Documents state dispatch />
<Profile state dispatch onLogout onAddVehicle onNav />
  ├── <FAQScreen onBack />
  ├── <IntervalsScreen vehicle dispatch onBack />
  └── <VehicleDetailScreen vehicle isFav dispatch onBack onGoToDashboard />
<Nav active onNav />
<CarSVG c={colorHex} />
<Badge color label />
<Bar health color />
<Btn v sz onClick disabled />
<Icon id size color />
<ColorPicker value onChange />
```

**Bug conocido resuelto:** `WorkshopForm` DEBE definirse fuera del componente `Workshop`. Si se define adentro, React lo remonta en cada render y los textarea pierden el foco tras cada keystroke.

---

## PWA

```
manifest.json  → name, short_name, theme_color #2EC864, background_color #060A07
sw.js          → cache offline de assets estáticos + CDN scripts
icon-192.png   → ícono home screen
icon-512.png   → splash screen
```

Tags en `<head>`:
```html
<link rel="manifest" href="manifest.json">
<meta name="theme-color" content="#2EC864">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<link rel="apple-touch-icon" href="icon-192.png">
```

---

## Lo que falta / backlog

| Feature | Prioridad | Notas |
|---------|-----------|-------|
| Login real | Alta | El actual es decorativo. Supabase Auth recomendado |
| Sync cloud | Alta | Supabase + PostgreSQL. Gratis para uso básico |
| Eliminar vehículo | Media | No implementado |
| Editar datos del vehículo | Media | Patente, km inicial, color, etc. |
| Notificaciones/recordatorios | Media | Requiere backend o push API |
| Historial con producto | Baja | Mostrar el producto usado en cada entrada del hist[] |
| Exportar PDF | Baja | Historial completo para vender el auto |
| QR del historial | Baja | Link público con historial read-only |
| Modo multi-usuario cloud | Futura | Cada usuario ve solo sus autos |

---

## Notas importantes para Claude Code

1. **No hay bundler.** Todo va en el HTML. Si migrás a Vite/Next, hay que adaptar los imports.

2. **React via CDN + Babel en el browser.** Los componentes usan JSX en `<script type="text/babel">`. Al migrar a proyecto real, cambiar a `.jsx` normal.

3. **WorkshopForm fuera de Workshop** es crítico. No moverlo adentro.

4. **localStorage key = `autito_v1`**. Cambiarla rompe los datos guardados de usuarios existentes — migrá con cuidado.

5. **El login actual es fake.** No hay sesiones reales, no hay JWT, no hay nada. Es solo `dispatch({type:'LOGIN', user:{email,name}})`.

6. **Vehículo activo = favorito.** El dashboard siempre muestra `vehicles.find(v => v.id === favoriteVehicleId) || vehicles[0]`. Workshop y History también filtran por este vehículo.

7. **Workshop filtra por `vid`** en cada entry. Entries legacy sin `vid` aparecen en todos los vehículos (retrocompatibilidad).

8. **Paleta de colores de autos** es un array de 16 objetos `{name, hex}` hardcodeado en `CAR_COLORS`. No viene del estado.

9. **MAINTS_DEFAULT** se clona al crear cada vehículo con `MAINTS_DEFAULT.map(m=>({...m}))`. Cada vehículo tiene su propia copia independiente.
