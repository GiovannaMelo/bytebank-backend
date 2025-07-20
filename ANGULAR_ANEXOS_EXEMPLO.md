# 📎 Sistema de Anexos - Exemplos para Angular

## 🎯 Visão Geral

Este documento mostra como integrar o sistema de anexos da API com um projeto Angular, incluindo upload, visualização e download de arquivos.

## 🚀 Endpoints Disponíveis

### **1. Upload de Anexo**
```
POST /account/transaction/{transactionId}/attachment
Content-Type: multipart/form-data
Authorization: Bearer {token}
```

### **2. Visualizar/Download Anexo**
```
GET /account/transaction/attachment/{filename}
Authorization: Bearer {token}
```

### **3. Remover Anexo**
```
DELETE /account/transaction/{transactionId}/attachment
Authorization: Bearer {token}
```

## 📁 Estrutura do Projeto Angular

### **1. Service para Anexos**

```typescript
// src/app/services/attachment.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Attachment {
  filename: string;
  originalName: string;
  mimetype: string;
  size: number;
  uploadDate: Date;
}

@Injectable({
  providedIn: 'root'
})
export class AttachmentService {
  private apiUrl = 'http://localhost:3000';

  constructor(private http: HttpClient) { }

  // Upload de anexo
  uploadAttachment(transactionId: string, file: File): Observable<any> {
    const formData = new FormData();
    formData.append('file', file);

    const headers = new HttpHeaders({
      'Authorization': `Bearer ${this.getToken()}`
    });

    return this.http.post(
      `${this.apiUrl}/account/transaction/${transactionId}/attachment`,
      formData,
      { headers }
    );
  }

  // Obter URL do anexo
  getAttachmentUrl(filename: string): string {
    return `${this.apiUrl}/account/transaction/attachment/${filename}`;
  }

  // Download de anexo
  downloadAttachment(filename: string): Observable<Blob> {
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${this.getToken()}`
    });

    return this.http.get(
      `${this.apiUrl}/account/transaction/attachment/${filename}`,
      { 
        headers,
        responseType: 'blob'
      }
    );
  }

  // Remover anexo
  removeAttachment(transactionId: string): Observable<any> {
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${this.getToken()}`
    });

    return this.http.delete(
      `${this.apiUrl}/account/transaction/${transactionId}/attachment`,
      { headers }
    );
  }

  private getToken(): string {
    return localStorage.getItem('token') || '';
  }
}
```

### **2. Componente de Upload**

```typescript
// src/app/components/attachment-upload/attachment-upload.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { AttachmentService } from '../../services/attachment.service';

@Component({
  selector: 'app-attachment-upload',
  template: `
    <div class="attachment-upload">
      <input 
        type="file" 
        #fileInput 
        (change)="onFileSelected($event)"
        accept=".jpg,.jpeg,.png,.gif,.pdf,.txt"
        style="display: none;"
      >
      
      <button 
        type="button" 
        class="btn btn-primary"
        (click)="fileInput.click()"
        [disabled]="uploading"
      >
        <i class="fas fa-paperclip"></i>
        {{ uploading ? 'Enviando...' : 'Anexar Arquivo' }}
      </button>

      <div *ngIf="uploading" class="progress mt-2">
        <div class="progress-bar" [style.width.%]="uploadProgress"></div>
      </div>

      <div *ngIf="error" class="alert alert-danger mt-2">
        {{ error }}
      </div>
    </div>
  `,
  styles: [`
    .attachment-upload {
      margin: 10px 0;
    }
    
    .progress {
      height: 20px;
      background-color: #f5f5f5;
      border-radius: 4px;
      overflow: hidden;
    }
    
    .progress-bar {
      height: 100%;
      background-color: #007bff;
      transition: width 0.3s ease;
    }
  `]
})
export class AttachmentUploadComponent {
  @Input() transactionId!: string;
  @Output() uploadComplete = new EventEmitter<any>();
  @Output() uploadError = new EventEmitter<string>();

  uploading = false;
  uploadProgress = 0;
  error = '';

  constructor(private attachmentService: AttachmentService) {}

  onFileSelected(event: any): void {
    const file = event.target.files[0];
    if (file) {
      this.uploadFile(file);
    }
  }

  uploadFile(file: File): void {
    this.uploading = true;
    this.uploadProgress = 0;
    this.error = '';

    // Validar tamanho (5MB)
    if (file.size > 5 * 1024 * 1024) {
      this.error = 'Arquivo muito grande. Máximo 5MB.';
      this.uploading = false;
      return;
    }

    // Validar tipo
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'text/plain'];
    if (!allowedTypes.includes(file.type)) {
      this.error = 'Tipo de arquivo não permitido.';
      this.uploading = false;
      return;
    }

    this.attachmentService.uploadAttachment(this.transactionId, file)
      .subscribe({
        next: (response) => {
          this.uploading = false;
          this.uploadProgress = 100;
          this.uploadComplete.emit(response.result);
          
          // Reset file input
          const fileInput = document.querySelector('input[type="file"]') as HTMLInputElement;
          if (fileInput) fileInput.value = '';
        },
        error: (error) => {
          this.uploading = false;
          this.error = error.error?.message || 'Erro ao enviar arquivo';
          this.uploadError.emit(this.error);
        }
      });
  }
}
```

### **3. Componente de Visualização**

```typescript
// src/app/components/attachment-viewer/attachment-viewer.component.ts
import { Component, Input } from '@angular/core';
import { AttachmentService } from '../../services/attachment.service';

@Component({
  selector: 'app-attachment-viewer',
  template: `
    <div class="attachment-viewer" *ngIf="attachment">
      <div class="attachment-info">
        <i class="fas fa-paperclip"></i>
        <span class="filename">{{ attachment.originalName }}</span>
        <span class="size">({{ formatFileSize(attachment.size) }})</span>
      </div>

      <!-- Imagem -->
      <div *ngIf="isImage()" class="image-preview">
        <img 
          [src]="getAttachmentUrl()" 
          [alt]="attachment.originalName"
          class="img-fluid"
          (error)="onImageError($event)"
        >
      </div>

      <!-- PDF -->
      <div *ngIf="isPdf()" class="pdf-preview">
        <iframe 
          [src]="getAttachmentUrl() | safe" 
          width="100%" 
          height="400px"
          frameborder="0"
        ></iframe>
      </div>

      <!-- Outros arquivos -->
      <div *ngIf="!isImage() && !isPdf()" class="file-preview">
        <i class="fas fa-file"></i>
        <span>{{ attachment.originalName }}</span>
      </div>

      <div class="attachment-actions">
        <button 
          class="btn btn-sm btn-outline-primary"
          (click)="downloadFile()"
        >
          <i class="fas fa-download"></i> Download
        </button>
        
        <button 
          class="btn btn-sm btn-outline-danger"
          (click)="removeAttachment()"
        >
          <i class="fas fa-trash"></i> Remover
        </button>
      </div>
    </div>
  `,
  styles: [`
    .attachment-viewer {
      border: 1px solid #ddd;
      border-radius: 4px;
      padding: 15px;
      margin: 10px 0;
    }
    
    .attachment-info {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 10px;
    }
    
    .filename {
      font-weight: bold;
    }
    
    .size {
      color: #666;
      font-size: 0.9em;
    }
    
    .image-preview img {
      max-width: 100%;
      max-height: 300px;
      border-radius: 4px;
    }
    
    .pdf-preview {
      border: 1px solid #ddd;
      border-radius: 4px;
    }
    
    .file-preview {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 20px;
      background-color: #f8f9fa;
      border-radius: 4px;
    }
    
    .attachment-actions {
      margin-top: 15px;
      display: flex;
      gap: 10px;
    }
  `]
})
export class AttachmentViewerComponent {
  @Input() attachment: any;
  @Input() transactionId!: string;

  constructor(private attachmentService: AttachmentService) {}

  getAttachmentUrl(): string {
    return this.attachmentService.getAttachmentUrl(this.attachment.filename);
  }

  isImage(): boolean {
    return this.attachment.mimetype.startsWith('image/');
  }

  isPdf(): boolean {
    return this.attachment.mimetype === 'application/pdf';
  }

  formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }

  downloadFile(): void {
    this.attachmentService.downloadAttachment(this.attachment.filename)
      .subscribe((blob: Blob) => {
        const url = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = this.attachment.originalName;
        link.click();
        window.URL.revokeObjectURL(url);
      });
  }

  removeAttachment(): void {
    if (confirm('Tem certeza que deseja remover este anexo?')) {
      this.attachmentService.removeAttachment(this.transactionId)
        .subscribe({
          next: () => {
            // Emitir evento para atualizar a lista
            this.attachment = null;
          },
          error: (error) => {
            console.error('Erro ao remover anexo:', error);
            alert('Erro ao remover anexo');
          }
        });
    }
  }

  onImageError(event: any): void {
    event.target.style.display = 'none';
  }
}
```

### **4. Pipe para URLs Seguras**

```typescript
// src/app/pipes/safe.pipe.ts
import { Pipe, PipeTransform } from '@angular/core';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';

@Pipe({
  name: 'safe'
})
export class SafePipe implements PipeTransform {
  constructor(private sanitizer: DomSanitizer) {}

  transform(url: string): SafeResourceUrl {
    return this.sanitizer.bypassSecurityTrustResourceUrl(url);
  }
}
```

### **5. Uso no Componente Principal**

```typescript
// src/app/components/transaction-detail/transaction-detail.component.ts
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { TransactionService } from '../../services/transaction.service';

@Component({
  selector: 'app-transaction-detail',
  template: `
    <div class="transaction-detail" *ngIf="transaction">
      <h2>{{ transaction.description }}</h2>
      
      <div class="transaction-info">
        <p><strong>Valor:</strong> R$ {{ transaction.amount }}</p>
        <p><strong>Categoria:</strong> {{ transaction.category }}</p>
        <p><strong>Data:</strong> {{ transaction.date | date:'dd/MM/yyyy' }}</p>
      </div>

      <!-- Upload de anexo -->
      <app-attachment-upload
        [transactionId]="transaction.id"
        (uploadComplete)="onUploadComplete($event)"
        (uploadError)="onUploadError($event)"
      ></app-attachment-upload>

      <!-- Visualização de anexo -->
      <app-attachment-viewer
        *ngIf="transaction.anexo"
        [attachment]="transaction.anexo"
        [transactionId]="transaction.id"
      ></app-attachment-viewer>
    </div>
  `
})
export class TransactionDetailComponent implements OnInit {
  transaction: any;

  constructor(
    private route: ActivatedRoute,
    private transactionService: TransactionService
  ) {}

  ngOnInit(): void {
    const transactionId = this.route.snapshot.params['id'];
    this.loadTransaction(transactionId);
  }

  loadTransaction(id: string): void {
    this.transactionService.getTransaction(id)
      .subscribe({
        next: (response) => {
          this.transaction = response.result.transaction;
        },
        error: (error) => {
          console.error('Erro ao carregar transação:', error);
        }
      });
  }

  onUploadComplete(result: any): void {
    // Atualizar a transação com o novo anexo
    this.transaction.anexo = result.attachment;
    alert('Anexo enviado com sucesso!');
  }

  onUploadError(error: string): void {
    alert(`Erro: ${error}`);
  }
}
```

## 🔧 Configurações Necessárias

### **1. Módulo Principal**

```typescript
// src/app/app.module.ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';

import { AppComponent } from './app.component';
import { AttachmentUploadComponent } from './components/attachment-upload/attachment-upload.component';
import { AttachmentViewerComponent } from './components/attachment-viewer/attachment-viewer.component';
import { SafePipe } from './pipes/safe.pipe';

@NgModule({
  declarations: [
    AppComponent,
    AttachmentUploadComponent,
    AttachmentViewerComponent,
    SafePipe
  ],
  imports: [
    BrowserModule,
    HttpClientModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

### **2. Interceptor para Token**

```typescript
// src/app/interceptors/auth.interceptor.ts
import { Injectable } from '@angular/core';
import { HttpInterceptor, HttpRequest, HttpHandler, HttpEvent } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const token = localStorage.getItem('token');
    
    if (token) {
      req = req.clone({
        setHeaders: {
          Authorization: `Bearer ${token}`
        }
      });
    }
    
    return next.handle(req);
  }
}
```

## 🎨 Exemplos de Uso

### **1. Upload Simples**

```typescript
// Upload de arquivo
const file = event.target.files[0];
this.attachmentService.uploadAttachment(transactionId, file)
  .subscribe(response => {
    console.log('Anexo enviado:', response);
  });
```

### **2. Exibir Imagem**

```html
<!-- No template -->
<img [src]="getAttachmentUrl(attachment.filename)" 
     [alt]="attachment.originalName"
     class="img-fluid">
```

### **3. Download de Arquivo**

```typescript
// Download
this.attachmentService.downloadAttachment(filename)
  .subscribe(blob => {
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = originalName;
    link.click();
    window.URL.revokeObjectURL(url);
  });
```

## 🚀 Funcionalidades Implementadas

✅ **Upload de arquivos** (JPEG, PNG, GIF, PDF, TXT)  
✅ **Validação de tamanho** (máximo 5MB)  
✅ **Validação de tipo**  
✅ **Visualização de imagens**  
✅ **Visualização de PDFs**  
✅ **Download de arquivos**  
✅ **Remoção de anexos**  
✅ **Progress bar**  
✅ **Tratamento de erros**  
✅ **URLs seguras**  

## 📝 Notas Importantes

1. **CORS**: Certifique-se de que o backend permite requisições do domínio do Angular
2. **Token**: O token JWT deve estar disponível no localStorage
3. **Tamanho**: Arquivos maiores que 5MB serão rejeitados
4. **Tipos**: Apenas JPEG, PNG, GIF, PDF e TXT são aceitos
5. **Segurança**: URLs são sanitizadas para evitar XSS

---

**🎉 Sistema de Anexos pronto para uso no Angular!** 