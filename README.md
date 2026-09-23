# Asesor Borroso de Rightsizing EC2

Sistema experto borroso (FuzzyCLIPS) que recomienda *rightsizing* de instancias EC2 (AWS) a partir del uso de CPU y memoria.

## Archivos

- `BC_rightsizing.clp` — base de conocimiento (plantillas borrosas + reglas R1–R5)
- `BH_rightsizing.clp` — base de hechos (caso de prueba CPU=60 %, Memoria=55 %)

## Ejecución (FuzzyCLIPS)

```
(clear)
(load "BC_rightsizing.clp")
(load "BH_rightsizing.clp")
(reset)
(run)
```

