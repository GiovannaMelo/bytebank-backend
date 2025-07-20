# 📎 Sistema de Anexos - Documentação Completa

## 🎯 Visão Geral

O sistema de anexos permite que os usuários façam upload, visualizem e gerenciem arquivos anexados às transações. É perfeito para projetos Angular e outras aplicações web.

## 🚀 Funcionalidades

### ✅ **Upload de Arquivos**
- Suporte a múltiplos tipos: JPEG, PNG, GIF, PDF, TXT
- Validação de tamanho (máximo 5MB)
- Nomes únicos para evitar conflitos
- Validação de tipo MIME

### ✅ **Visualização**
- Imagens exibidas inline
- PDFs em iframe
- Download direto para outros tipos
- URLs seguras para Angular

### ✅ **Gerenciamento**
- Remoção de anexos
- Limpeza automática de arquivos órfãos
- Verificação de permissões

## 📋 Endpoints da API

### **1. Upload de Anexo**
```http
POST /account/transaction/{transactionId}/attachment
Content-Type: multipart/form-data
Authorization: Bearer {token}

Body: FormData com campo 'file'
```

**Resposta:**
```json
{
  "message": "Anexo enviado com sucesso",
  "result": {
    "transaction": { ... },
    "attachment": {
      "filename": "transaction-1234567890-123456789.jpg",
      "originalName": "comprovante.jpg",
      "mimetype": "image/jpeg",
      "size": 102400,
      "uploadDate": "2024-01-15T10:30:00.000Z"
    }
  }
}
```

### **2. Visualizar/Download Anexo**
```http
GET /account/transaction/attachment/{filename}
Authorization: Bearer {token}
```

**Resposta:** Arquivo binário com headers apropriados

### **3. Remover Anexo**
```http
DELETE /account/transaction/{transactionId}/attachment
Authorization: Bearer {token}
```

**Resposta:**
```json
{
  "message": "Anexo removido com sucesso",
  "result": {
    "transaction": { ... }
  }
}
```

## 🛠️ Configuração

### **1. Instalar Dependências**
```bash
npm install multer
```

### **2. Estrutura de Diretórios**
```
uploads/
├── transaction-1234567890-123456789.jpg
├── transaction-1234567890-123456790.pdf
└── transaction-1234567890-123456791.txt
```

### **3. Configurações do Multer**
- **Tamanho máximo:** 5MB
- **Tipos permitidos:** JPEG, PNG, GIF, PDF, TXT
- **Nomenclatura:** `transaction-{timestamp}-{random}.{ext}`

## 🧪 Testes

### **1. Script PowerShell**
```powershell
# Executar teste completo
.\teste-anexos.ps1
```

### **2. Postman Collection**
- Importar `tech-challenge-2.postman_collection.json`
- Configurar variáveis de ambiente
- Testar endpoints de anexos

### **3. Teste Manual**
```bash
# Upload
curl -X POST http://localhost:3000/account/transaction/123/attachment \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@comprovante.jpg"

# Download
curl -X GET http://localhost:3000/account/transaction/attachment/filename \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -o downloaded_file.jpg
```

## 📱 Integração com Angular

### **1. Service**
```typescript
@Injectable()
export class AttachmentService {
  uploadAttachment(transactionId: string, file: File): Observable<any> {
    const formData = new FormData();
    formData.append('file', file);
    
    return this.http.post(
      `${this.apiUrl}/account/transaction/${transactionId}/attachment`,
      formData,
      { headers: this.getAuthHeaders() }
    );
  }
}
```

### **2. Componente**
```typescript
@Component({
  template: `
    <input type="file" (change)="onFileSelected($event)">
    <img *ngIf="attachment" [src]="getAttachmentUrl()">
  `
})
export class AttachmentComponent {
  onFileSelected(event: any) {
    const file = event.target.files[0];
    this.attachmentService.uploadAttachment(this.transactionId, file)
      .subscribe(response => {
        this.attachment = response.result.attachment;
      });
  }
}
```

## 🔒 Segurança

### **1. Validações**
- ✅ Tipo de arquivo permitido
- ✅ Tamanho máximo
- ✅ Autenticação obrigatória
- ✅ Verificação de propriedade da transação

### **2. Sanitização**
- ✅ Nomes de arquivo únicos
- ✅ Remoção de caracteres especiais
- ✅ URLs seguras para Angular

### **3. Limpeza**
- ✅ Remoção de arquivos órfãos
- ✅ Limpeza automática em erros
- ✅ Verificação de existência

## 📊 Estrutura de Dados

### **Transação com Anexo**
```json
{
  "id": "123",
  "description": "Compra no supermercado",
  "amount": 150.50,
  "anexo": {
    "filename": "transaction-1234567890-123456789.jpg",
    "originalName": "comprovante.jpg",
    "mimetype": "image/jpeg",
    "size": 102400,
    "uploadDate": "2024-01-15T10:30:00.000Z"
  }
}
```

## 🎨 Exemplos de Uso

### **1. Upload Simples**
```javascript
// Frontend
const fileInput = document.querySelector('input[type="file"]');
const file = fileInput.files[0];

const formData = new FormData();
formData.append('file', file);

fetch('/account/transaction/123/attachment', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + token
  },
  body: formData
});
```

### **2. Exibir Imagem**
```html
<!-- Angular -->
<img [src]="apiUrl + '/account/transaction/attachment/' + attachment.filename" 
     [alt]="attachment.originalName">

<!-- HTML puro -->
<img src="http://localhost:3000/account/transaction/attachment/filename.jpg">
```

### **3. Download**
```javascript
// Angular
this.http.get(url, { responseType: 'blob' })
  .subscribe(blob => {
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = originalName;
    link.click();
  });
```

## 🚨 Tratamento de Erros

### **1. Erros Comuns**
```json
{
  "message": "Nenhum arquivo foi enviado",
  "result": null
}

{
  "message": "Tipo de arquivo não permitido. Tipos aceitos: JPEG, PNG, GIF, PDF, TXT",
  "result": null
}

{
  "message": "Transação não encontrada",
  "result": null
}
```

### **2. Validações Frontend**
```typescript
// Validar tamanho
if (file.size > 5 * 1024 * 1024) {
  alert('Arquivo muito grande. Máximo 5MB.');
  return;
}

// Validar tipo
const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'text/plain'];
if (!allowedTypes.includes(file.type)) {
  alert('Tipo de arquivo não permitido.');
  return;
}
```

## 📝 Logs e Debug

### **1. Logs do Servidor**
```javascript
console.log('Upload de anexo:', {
  transactionId,
  filename: file.filename,
  size: file.size,
  mimetype: file.mimetype
});
```

### **2. Verificação de Arquivos**
```javascript
// Verificar se arquivo existe
const fileInfo = getFileInfo(filename);
if (fileInfo) {
  console.log('Arquivo encontrado:', fileInfo);
} else {
  console.log('Arquivo não encontrado');
}
```

## 🔧 Manutenção

### **1. Limpeza de Arquivos Órfãos**
```javascript
// Script para limpeza periódica
function cleanupOrphanFiles() {
  // Implementar lógica de limpeza
  // Verificar arquivos sem transação correspondente
}
```

### **2. Backup**
```bash
# Backup da pasta uploads
tar -czf uploads-backup.tar.gz uploads/
```

### **3. Monitoramento**
```javascript
// Monitorar uso de disco
const fs = require('fs');
const stats = fs.statSync('./uploads');
console.log('Tamanho da pasta uploads:', stats.size);
```

## 🎯 Próximos Passos

### **1. Melhorias Futuras**
- [ ] Upload múltiplo de arquivos
- [ ] Compressão de imagens
- [ ] Thumbnails automáticos
- [ ] Integração com cloud storage
- [ ] Versionamento de arquivos

### **2. Otimizações**
- [ ] Cache de arquivos
- [ ] Streaming para arquivos grandes
- [ ] CDN para distribuição
- [ ] Compressão automática

---

## 📞 Suporte

Para dúvidas ou problemas:
1. Verificar logs do servidor
2. Executar testes automatizados
3. Consultar documentação do Angular
4. Verificar configurações de CORS

**🎉 Sistema de Anexos pronto para produção!** 