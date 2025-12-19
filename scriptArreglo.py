import pandas as pd
import ftfy

# Read CSV as latin1 to preserve the garbled bytes
df = pd.read_csv(r'rutaArchivo\a2_anon.csv', 
                 encoding='latin1', sep=';')

# Fix all string columns
for col in df.select_dtypes(include='object').columns:
    df[col] = df[col].apply(lambda x: ftfy.fix_text(x) if isinstance(x, str) else x)

# Save the corrected CSV as UTF-8
df.to_csv(r'rutaArchivo\a2_anon_arreglado.csv', 
          index=False, encoding='utf-8', sep=';')
