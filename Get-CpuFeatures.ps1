# Asegúrate de que PowerShell está en modo de administrador si es necesario
# Para ejecutar, guárdalo como Get-CpuFeatures.ps1 y correlo con .\Get-CpuFeatures.ps1

# Función para obtener información del procesador
function Get-CpuDetails {
    # Obtiene detalles del procesador usando WMI
    $processor = Get-CimInstance -ClassName Win32_Processor | Select-Object @(
        'Name',
        'MaxClockSpeed',
        'AddressWidth',
        'LogicalProcessorCount',
        'NumberOfCores',
        'X86Pipelining',
        'Manufacturer',
        'Family'
    )

    # Obtiene información adicional del sistema
    $system = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object @(
        'Model',
        'Manufacturer',
        'TotalPhysicalMemory',
        'Name'
    )

    return @{
        Processor = $processor
        System    = $system
    }
}

# Función para verificar compatibilidad con características específicas (ej. SSE, AVX)
function Test-CpuFeatures {
    # Compatibilidad con instrucciones SIMD (SSE, AVX) y otras tecnologías
    $features = @{}

    # Verifica si el procesador soporta Hyper-Threading o múltiples hilos lógicos
    if ($global:processor.LogicalProcessorCount -gt $global:processor.NumberOfCores) {
        $features['HyperThreading'] = 'Sí'
    } else {
        $features['HyperThreading'] = 'No'
    }

    # Compatibilidad con instrucciones SIMD (ej. SSE, AVX)
    if ((Get-CimInstance -ClassName Win32_Processor).DataWidth -ge 128) {
        $features['SSESupport'] = 'Sí'
    } else {
        $features['SSESupport'] = 'No'
    }

    # Compatibilidad con AVX (Advanced Vector Extensions)
    if ((Get-CimInstance -ClassName Win32_Processor).DataWidth -ge 128) {
        $features['AVXSupport'] = 'Sí'
    } else {
        $features['AVxSupport'] = 'No'
    }

    return $features
}

# Función principal para mostrar información del CPU
function Show-CpuInfo {
    # Obtiene los datos del procesador y sistema
    $cpuData = Get-CpuDetails

    # Imprime la información en el consola
    Write-Host "=== Información del Procesador ==="
    Write-Host "Modelo: $($cpuData.Processor.Name)"
    Write-Host "Familia: $($cpuData.Processor.Family)"
    Write-Host "Fabricante: $($cpuData.Processor.Manufacturer)"
    Write-Host "Núcleos lógicos: $($cpuData.Processor.LogicalProcessorCount)"
    Write-Host "Núcleos físicos: $($cpuData.Processor.NumberOfCores)"
    Write-Host "Velocidad máxima (MHz): $([math]::Round($cpuData.Processor.MaxClockSpeed, 2))"
    Write-Host "Ancho de dirección: $([math]::Round($cpuData.Processor.AddressWidth, 0)) bits"
    Write-Host ""

    # Muestra compatibilidad con características específicas
    Write-Host "=== Características del CPU ==="
    foreach ($feature in (Test-CpuFeatures).GetEnumerator()) {
        Write-Host "$($feature.Key): $($feature.Value)"
    }

    Write-Host ""
    Write-Host "=== Información del Sistema ==="
    Write-Host "Modelo del sistema: $($cpuData.System.Model)"
    Write-Host "Fabricante del sistema: $($cpuData.System.Manufacturer)"
    Write-Host "Memoria RAM total (GB): $([math]::Round($cpuData.System.TotalPhysicalMemory / 1GB, 2))"
    Write-Host ""
}

# Ejecuta la función principal
Show-CpuInfo
