# DLS26 — Guía táctica de referencia

## Lectura rápida de la captura
1. ¿Quién tiene el balón? (indicador/anillo sobre el jugador controlado)
2. ¿Hacia dónde ataco? (portería rival; cambia en el 2.º tiempo)
3. ¿En qué tercio estoy? (defensivo / medio / ofensivo)
4. ¿Rival a menos de ~2 m? → presión inmediata
5. ¿Compañero libre adelante o al costado? → opción de pase
6. Minuto y marcador → nivel de riesgo

## Árbol de decisión con balón
| Situación | Acción | Comando típico |
|---|---|---|
| Presión inmediata en tercio propio | Pase corto seguro o atrás | `tap PASS` |
| Espacio libre delante | Conducir con sprint corto | `move E 700` (+ SPRINT si existe) |
| Delantero en carrera, espacio tras la defensa | Pase al hueco | `tap THROUGH` |
| Banda saturada | Cambio de orientación | `lob PASS` hacia el lado débil |
| Extremo en línea de fondo | Centro al segundo palo | `lob THROUGH` |
| Dentro del área con ángulo | Tiro colocado | `hold SHOOT 350` |
| 1 vs 1 con el portero | Tiro suave al palo lejano | `combo x DIR 400 SHOOT 250` |
| Defensor de frente, sin apoyo | Cambio de dirección 45–90° | `move NE 300` → `move SE 300` |

## Árbol de decisión sin balón
| Situación | Acción |
|---|---|
| El jugador controlado quedó atrás de la jugada | Cambiar jugador (`tap PASS`) |
| Rival conduce hacia tu área | Ponte entre balón y portería, acompaña sin barrer |
| Rival de espaldas a tu portería | Presionar (`hold THROUGH 500`) |
| Rival se adelanta el balón | Entrada (`tap SHOOT`) |
| Último defensor | Nunca barrer; temporizar hasta que llegue ayuda |
| Centro rival | Controlar al central más cercano al punto de penal |

## Formaciones
- **4-3-3**: equilibrio y presión alta; buena con extremos rápidos.
- **4-2-3-1**: dos medios defensivos, ideal contra rivales superiores.
- **4-4-2**: sólida y simple, buena para contraataque.
- **3-5-2**: solo con carrileros con mucha resistencia.

## Gestión de energía y cambios
- Barra amarilla/roja → cambiar en el descanso o min. 60–70.
- Prioriza cambiar extremos y medios (más desgaste).

## Penales
- Tirando: elige esquina antes de la carrera; potencia media (≈50–70% de la
  barra); raso y pegado al palo. Alterna lados entre tiros.
- Atajando: si el rival repite lado dos veces, cubre ese lado la tercera.

## Errores comunes a evitar
- Sprint permanente (pierde el balón y la energía).
- Pases horizontales en el tercio propio.
- Tiros desde fuera del área con defensas.
- Barridas por detrás (tarjeta) o dentro del área (penal).
