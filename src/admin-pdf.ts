export type PdfInvoice={
  number:string
  issueDate:string
  dueDate:string
  client:{name:string;company?:string;email?:string;phone?:string;address?:string;taxId?:string}
  items:{description:string;quantity:number;unitPrice:number}[]
  taxRate:number
  notes?:string
}

const clean=(value:string)=>value.normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^\x20-\x7E]/g,'')
const esc=(value:string)=>clean(value).replace(/([\\()])/g,'\\$1')
const fmt=(value:number)=>new Intl.NumberFormat('fr-FR').format(Math.round(value))+' GNF'

export function downloadInvoicePdf(invoice:PdfInvoice){
  const subtotal=invoice.items.reduce((sum,item)=>sum+item.quantity*item.unitPrice,0)
  const tax=subtotal*invoice.taxRate/100
  const total=subtotal+tax
  const commands:string[]=['0.08 0.09 0.09 rg','0 0 595 842 re f','1 1 1 rg','BT','/F1 12 Tf','50 790 Td','(GRS VISION) Tj','ET','0.72 0.74 0.72 rg','BT','/F1 9 Tf','50 772 Td','(Studio photo & film - Conakry, Guinee) Tj','ET','0.83 1 0.25 rg','BT','/F1 10 Tf','400 790 Td',`(FACTURE ${esc(invoice.number)}) Tj`,'ET']
  commands.push('1 1 1 rg','BT','/F1 24 Tf','50 710 Td',`(${esc(invoice.client.company||invoice.client.name)}) Tj`,'ET','0.7 0.72 0.7 rg','BT','/F1 10 Tf','50 690 Td',`(${esc(invoice.client.name)}) Tj`,'ET')
  let cy=674
  for(const line of [invoice.client.email||'',invoice.client.phone||'',invoice.client.address||'',invoice.client.taxId?`NIF: ${invoice.client.taxId}`:''].filter(Boolean)){commands.push('BT','/F1 9 Tf',`50 ${cy} Td`,`(${esc(line)}) Tj`,'ET');cy-=14}
  commands.push('0.45 0.47 0.45 rg','BT','/F1 9 Tf','390 710 Td',`(Emission: ${esc(invoice.issueDate)}) Tj`,'ET','BT','/F1 9 Tf','390 694 Td',`(Echeance: ${esc(invoice.dueDate)}) Tj`,'ET')
  let y=590
  commands.push('0.83 1 0.25 rg','0.7 w',`50 ${y} m 545 ${y} l S`,'BT','/F1 9 Tf',`50 ${y-20} Td`,'(DESCRIPTION) Tj','ET','BT','/F1 9 Tf',`340 ${y-20} Td`,'(QTE) Tj','ET','BT','/F1 9 Tf',`400 ${y-20} Td`,'(PRIX) Tj','ET','BT','/F1 9 Tf',`485 ${y-20} Td`,'(TOTAL) Tj','ET')
  y-=50
  invoice.items.forEach(item=>{const lineTotal=item.quantity*item.unitPrice;commands.push('1 1 1 rg','BT','/F1 10 Tf',`50 ${y} Td`,`(${esc(item.description.slice(0,42))}) Tj`,'ET','BT','/F1 9 Tf',`345 ${y} Td`,`(${item.quantity}) Tj`,'ET','BT','/F1 9 Tf',`395 ${y} Td`,`(${esc(fmt(item.unitPrice))}) Tj`,'ET','BT','/F1 9 Tf',`475 ${y} Td`,`(${esc(fmt(lineTotal))}) Tj`,'ET','0.18 0.2 0.19 rg',`50 ${y-12} m 545 ${y-12} l S`);y-=34})
  const totalsY=Math.max(160,y-20)
  commands.push('0.7 0.72 0.7 rg','BT','/F1 10 Tf',`360 ${totalsY} Td`,'(Sous-total) Tj','ET','1 1 1 rg','BT','/F1 10 Tf',`455 ${totalsY} Td`,`(${esc(fmt(subtotal))}) Tj`,'ET','0.7 0.72 0.7 rg','BT','/F1 10 Tf',`360 ${totalsY-22} Td`,`(Taxe ${invoice.taxRate}%) Tj`,'ET','1 1 1 rg','BT','/F1 10 Tf',`455 ${totalsY-22} Td`,`(${esc(fmt(tax))}) Tj`,'ET','0.83 1 0.25 rg','BT','/F1 15 Tf',`360 ${totalsY-54} Td`,'(TOTAL) Tj','ET','BT','/F1 15 Tf',`445 ${totalsY-54} Td`,`(${esc(fmt(total))}) Tj`,'ET')
  if(invoice.notes)commands.push('0.65 0.67 0.65 rg','BT','/F1 8 Tf','50 90 Td',`(${esc(invoice.notes.slice(0,90))}) Tj`,'ET')
  commands.push('0.5 0.52 0.5 rg','BT','/F1 8 Tf','50 46 Td','(Merci pour votre confiance. GRS VISION - document genere depuis Studio OS.) Tj','ET')
  const stream=commands.join('\n')
  const objects=[
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>',
    `<< /Length ${stream.length} >>\nstream\n${stream}\nendstream`,
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>'
  ]
  let pdf='%PDF-1.4\n',offsets=[0]
  objects.forEach((obj,index)=>{offsets.push(pdf.length);pdf+=`${index+1} 0 obj\n${obj}\nendobj\n`})
  const xref=pdf.length
  pdf+=`xref\n0 ${objects.length+1}\n0000000000 65535 f \n`
  offsets.slice(1).forEach(offset=>{pdf+=String(offset).padStart(10,'0')+' 00000 n \n'})
  pdf+=`trailer\n<< /Size ${objects.length+1} /Root 1 0 R >>\nstartxref\n${xref}\n%%EOF`
  const blob=new Blob([pdf],{type:'application/pdf'})
  const url=URL.createObjectURL(blob)
  const link=document.createElement('a');link.href=url;link.download=`${invoice.number}.pdf`;link.click()
  window.setTimeout(()=>URL.revokeObjectURL(url),1500)
}
