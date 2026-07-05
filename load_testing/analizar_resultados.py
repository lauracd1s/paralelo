import json
import sys
from datetime import datetime

def parse_k6_results(json_file):
    """Parsea el archivo JSON de k6 y extrae métricas clave"""
    
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"❌ Archivo no encontrado: {json_file}")
        return
    except json.JSONDecodeError:
        print(f"❌ Error parseando JSON: {json_file}")
        return

    print("\n" + "="*60)
    print(f"📊 ANÁLISIS DE RESULTADOS K6")
    print(f"Archivo: {json_file}")
    print(f"Generado: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*60 + "\n")

    # Extraer métricas de k6
    metrics = data.get('metrics', {})
    
    # HTTP Requests
    http_reqs = metrics.get('http_reqs', {})
    http_req_duration = metrics.get('http_req_duration', {})
    http_req_failed = metrics.get('http_req_failed', {})
    
    print("🌐 HTTP REQUESTS")
    print("-" * 60)
    if 'value' in http_reqs:
        print(f"Total de requests: {int(http_reqs['value'])}")
    
    print("\n⏱️  DURACIÓN (ms)")
    print("-" * 60)
    if 'values' in http_req_duration:
        values = http_req_duration['values']
        print(f"Mínima: {values.get('min', 'N/A')} ms")
        print(f"Máxima: {values.get('max', 'N/A')} ms")
        print(f"Media: {values.get('avg', 'N/A')} ms")
        print(f"P50: {values.get('med', 'N/A')} ms")
        print(f"P95: {values.get('p(95)', 'N/A')} ms")
        print(f"P99: {values.get('p(99)', 'N/A')} ms")
    
    print("\n❌ ERRORES")
    print("-" * 60)
    if 'value' in http_req_failed:
        failed = int(http_req_failed['value'])
        total = int(http_reqs.get('value', 1))
        error_rate = (failed / total * 100) if total > 0 else 0
        print(f"Requests fallidas: {failed}")
        print(f"Tasa de errores: {error_rate:.2f}%")
    
    # VU Stats
    print("\n👥 USUARIOS VIRTUALES")
    print("-" * 60)
    vu = metrics.get('vus', {})
    if 'value' in vu:
        print(f"Usuarios en el pico: {int(vu['value'])}")
    vu_max = metrics.get('vus_max', {})
    if 'value' in vu_max:
        print(f"Máximo configurado: {int(vu_max['value'])}")
    
    # Iterations
    print("\n🔁 ITERACIONES")
    print("-" * 60)
    iterations = metrics.get('iteration_duration', {})
    if 'values' in iterations:
        values = iterations['values']
        print(f"Total de iteraciones: {values.get('count', 'N/A')}")
    
    print("\n" + "="*60)
    print("✅ Análisis completado")
    print("="*60 + "\n")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python analyze_results.py <archivo.json>")
        print("Ejemplo: python analyze_results.py resultados/baseline.json")
        sys.exit(1)
    
    json_file = sys.argv[1]
    parse_k6_results(json_file)
