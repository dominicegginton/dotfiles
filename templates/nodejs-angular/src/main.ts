import { bootstrapApplication } from '@angular/platform-browser';
import { Component } from '@angular/core';

@Component({
  standalone: true,
  selector: 'app-root',
  template: ``
})
export class AppComponent {}

bootstrapApplication(AppComponent).catch(console.error)
