---
name: dls26-control
description: Controla Dream League Soccer 2026 (DLS26) en un emulador Android o un teléfono conectado por ADB y juega con criterio de jugador profesional (ataque, defensa, balón parado, penales, tácticas y gestión del equipo). Úsala cuando el usuario pida jugar, practicar, configurar o automatizar partidos de DLS26 / Dream League Soccer en modos sin conexión.
---

# DLS26 — Control y juego profesional

Esta skill le permite a Claude **ver la pantalla** de DLS26 (capturas) y **mandar
entradas táctiles** (joystick virtual, botones, gestos) a través de ADB o del
control de escritorio (computer use), tomando decisiones como un jugador
profesional.

## 0. Reglas antes de empezar

- **Solo modos offline / contra la IA**: Carrera, partidos amistosos, eventos
  para un jugador, entrenamiento. **Nunca** usar la automatización en Online,
  Live Events competitivos ni en divisiones contra otros jugadores: eso es
  hacer trampa y puede violar los términos de First Touch Games (riesgo de ban).
  Si el usuario lo pide, explícalo y ofrece jugar un modo offline.
- No comprar monedas/diamantes ni aceptar compras dentro de la app sin
  confirmación explícita del usuario.
- Sé honesto sobre la latencia: cada ciclo "captura → decidir → tocar" tarda
  ~0.5–2 s. Claude rinde muy bien en menús, tácticas, balón parado y penales;
  en juego abierto en tiempo real juega por **ráfagas cortas** (ver §4).

> Todas las rutas `scripts/...` son relativas a la carpeta de esta skill
> (`.claude/skills/dls26-control/`).

## 1. Conexión

El juego corre en el equipo del usuario (BlueStacks, LDPlayer, Android Studio
Emulator o un teléfono con depuración USB). Desde una sesión en la nube hay que
adjuntar su computadora primero (list_computer_folders → request_computer_folder)
y ejecutar los comandos allí.

Opción A — **ADB (recomendada, más rápida y precisa)**:
```bash
adb devices                       # debe listar el dispositivo
# BlueStacks/LDPlayer: adb connect 127.0.0.1:5555 (el puerto lo muestra el emulador)
bash scripts/dls.sh check         # verifica conexión, resolución y que DLS esté abierto
```

Opción B — **Computer use**: carga la skill `anthropic-skills:computer-use`,
toma capturas de la ventana del emulador y haz clic/arrastra con el ratón.
Úsala solo si no hay ADB (no permite mantener pulsados dos controles a la vez).

## 2. Calibración (una sola vez por dispositivo)

Las coordenadas cambian según resolución y la configuración de controles.
1. `bash scripts/dls.sh shot` → guarda `/tmp/dls_screen.png`; ábrela con Read.
2. Entra a un partido amistoso y pausa en juego para ver los controles.
3. Ubica el centro del joystick y de cada botón y escríbelos en
   `scripts/dls.conf` (copia `dls.conf.example`). Los valores están en
   **píxeles reales** del dispositivo (`adb shell wm size`).
4. Prueba cada botón con `bash scripts/dls.sh tap PASS` en el modo
   Entrenamiento y corrige.

Mapa por defecto de DLS (revisar en Ajustes → Controles, puede variar):

| Control | En ataque | En defensa |
|---|---|---|
| Joystick (izquierda) | Mover / regatear | Mover |
| `PASS` = `A` (abajo-derecha) | Pase al pie / chute fuerte | Entrada deslizante |
| `SHOOT` = `B` (izquierda de A) | Tiro (mantener = potencia) / chute raso | Presión (mantener) |
| `THROUGH` = `C` (encima de A) | Pase al hueco / chute elevado | Cambiar de jugador |
| `SPRINT` (si existe en tu layout) | Correr | Correr |

En defensa usa los alias por letra para no confundirte: `tap C` cambia de
jugador, `hold B 500` presiona y `tap A` es la barrida.

Gestos útiles: deslizar desde el botón de tiro/pase hacia arriba = pase/tiro
**bombeado**; deslizar con curva = **efecto**; doble toque en pase al hueco =
**globo al espacio**. Verifica cada uno en Entrenamiento antes de usarlo.

## 3. Script de control (`scripts/dls.sh`)

```bash
bash scripts/dls.sh shot                       # captura de pantalla
bash scripts/dls.sh tap PASS                   # toque corto
bash scripts/dls.sh hold SHOOT 600             # mantener 600 ms (potencia de tiro)
bash scripts/dls.sh move NE 800                # joystick hacia noreste 800 ms
bash scripts/dls.sh move 35 600                # joystick a 35° (0=derecha, 90=arriba)
bash scripts/dls.sh lob THROUGH                # gesto de pase bombeado
bash scripts/dls.sh combo run_shoot NE 700 SHOOT 450   # correr y rematar
bash scripts/dls.sh xy 1200 640                # tocar coordenada (menús)
```

`combo` ejecuta joystick y botón **en paralelo** (necesario para tirar o pasar
mientras se corre). Direcciones: `N NE E SE S SW W NW` o grados.
**Importante:** la dirección de ataque cambia en el segundo tiempo; determínala
siempre con la captura (dónde está la portería rival), no de memoria.

## 4. Bucle de juego

Repite mientras dure el partido:

1. **Ver**: `dls.sh shot` y lee la captura. Identifica: quién tiene el balón
   (indicador sobre el jugador controlado), zona del campo (tercio defensivo /
   medio / ofensivo), dirección de la portería rival, compañeros libres,
   rivales cercanos y el reloj/marcador.
2. **Decidir** con la guía de §5 (una acción concreta de 0.3–1.5 s).
3. **Actuar** con 1–3 comandos encadenados en una sola llamada Bash.
4. Vuelve a 1. Si el juego quedó en pausa, en repetición o en un menú, sal con
   el botón correspondiente antes de continuar.

Para reducir la latencia: encadena "acción + captura" en la misma llamada
(`dls.sh move E 500 && dls.sh shot`) y prefiere jugadas simples y seguras.
Si la latencia hace imposible el juego abierto, propón al usuario que Claude
lleve tácticas, alineación, cambios, balón parado y penales mientras el usuario
juega el balón en movimiento.

## 5. Cómo juega un profesional

Resumen operativo (detalle en `references/tactics.md`):

**Con balón**
- Primero la seguridad: si hay presión a ≤1 jugador de distancia y no hay
  pase claro, protege (movimiento corto lateral) o pase atrás.
- Pase corto al compañero más libre en la dirección del avance; el pase al
  hueco solo si el receptor ya va corriendo y hay espacio detrás de la defensa.
- Cambia el juego (pase largo / bombeado) cuando un lado está saturado.
- No esprintes todo el tiempo: el sprint reduce el control del balón y la
  resistencia. Sprint solo con espacio libre delante.
- Regate: cambio de dirección de 45–90° justo antes del contacto con el
  defensor; evita regatear en tu propio tercio.

**Tiro**
- Dentro del área y con ángulo: tiro raso/colocado, potencia baja-media
  (`hold SHOOT 250–450`), apuntando al palo lejano.
- Fuera del área: solo con jugador de buen tiro y sin bloqueo; más potencia
  (`450–650 ms`) con efecto hacia dentro.
- Uno contra uno con el portero: tiro suave colocado o pase lateral al
  compañero; nunca potencia máxima (se va por encima).

**Sin balón**
- No persigas con el jugador más cercano a ciegas: cambia al defensor que
  queda entre el balón y la portería (`tap PASS`).
- Mantén la línea: acompaña (`move`) en vez de barrer. La barrida (`SHOOT`)
  solo desde el frente/lateral y nunca dentro del área.
- Presiona (`THROUGH`) en el tercio ofensivo rival o cuando el rival recibe de
  espaldas.

**Balón parado y penales**
- Córners: centro bombeado al primer o segundo palo donde esté tu cabeceador.
- Faltas directas a 20–28 m: efecto por encima de la barrera hacia el palo
  del portero descubierto.
- Penales (tirando): elige esquina, potencia media (sin pasar ~70% de la
  barra). Varía la esquina entre penales.
- Penales (atajando): observa la carrera del tirador y lánzate al lado de su
  pie hábil cuando corre abierto; alterna si el rival repite patrón.

**Gestión del partido**
- Antes del partido: revisa formación (4-3-3 o 4-2-3-1 equilibradas, 4-4-2 si
  el rival es más rápido), alinea jugadores con energía alta.
- Ganando por la mínima a partir del min. 75: posesión, pases cortos, cambios
  defensivos. Perdiendo: más jugadores arriba, centros y tiros de media
  distancia.
- Haz los cambios en el descanso o con jugadores con poca energía (barra
  roja/amarilla).

## 6. Al terminar

Informa al usuario: resultado, qué jugadas funcionaron, errores recurrentes
(p. ej. pases interceptados en el centro) y ajustes recomendados de táctica o
calibración. Si algo de la calibración cambió, actualiza `scripts/dls.conf`.
