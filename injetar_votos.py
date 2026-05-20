import json
import random
from datetime import datetime

# --- CONFIGURAÇÃO DO TESTE ---
# IDs que devem existir no seu banco para o vínculo funcionar
candidatos = [
    {"id": "1", "nome": "Candidato A", "bairro": "Centro"},
    {"id": "2", "nome": "Candidato B", "bairro": "Vila Nova"}
]
bairros_foco = ["Centro", "Vila Nova", "Bairro Alto", "Industrial", "Cohab"]

def gerar_votos_teste(quantidade=20):
    votos_gerados = []
    
    for i in range(quantidade):
        # Escolhe um candidato e um bairro aleatoriamente
        cand = random.choice(candidatos)
        bairro = random.choice(bairros_foco)
        
        voto = {
            "idEleitor": f"COLETADO_{datetime.now().strftime('%M%S')}_{i}",
            "idCandidato": cand["id"],
            "dataVoto": datetime.now().isoformat(),
            "tipoVoto": "pesquisa_campo",
            "bairro_origem": bairro  # Para o seu mapa de calor (Azul/Vermelho)
        }
        votos_gerados.append(voto)
    
    return votos_gerados

# --- EXECUÇÃO ---
votos = gerar_votos_teste(20)

# Salva em um arquivo JSON para o senhor inspecionar
with open('votos_teste.json', 'w', encoding='utf-8') as f:
    json.dump(votos, f, indent=4, ensure_ascii=False)

print(f"✅ Sucesso! {len(votos)} votos gerados no arquivo 'votos_teste.json'.")
print("--------------------------------------------------")
print("Doutor Ademir, agora o senhor tem a 'matéria-prima'.")
print("Quer que eu prepare a função no Flutter para LER esse arquivo?")