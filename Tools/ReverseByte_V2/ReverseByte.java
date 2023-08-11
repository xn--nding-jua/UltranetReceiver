//Package à importer afin d'utiliser l'objet File
import java.io.File;
import java.io.*;

public class ReverseByte {
  public static void main(String[] args) {


	try {
		
			System.out.println ("Inversion bits pour MKRVIDOR4000");	
			System.out.println ("www.systemes-embarques.fr");	
			FileReader input = new FileReader(args[0]);
			BufferedReader bufRead = new BufferedReader(input);
			String myLine = null;

			java.io.BufferedWriter sortie = new BufferedWriter (new FileWriter (args[1]));

			while ( (myLine = bufRead.readLine()) != null)
			{    
				String[] array1 = myLine.split(",");
				for (int i = 0; i < array1.length; i++)
				{
					int source = Integer.parseInt(array1[i].trim());
					int result = 0;
					for (int j=0; j<8;j++) 
					{ 
						result= result >> 1;
						if ((source&0x80)==0x80) result += 0x80;
						source = source << 1;
					}
					sortie.write(Integer.toString(result));
					sortie.write(",");
					if ((i+1)%16==0) sortie.write("\n");
				}
			}
			sortie.close();
			System.out.println ("***Fin de creation fichier***");	

	
	}
	catch (IOException e) {
      }
  }
}
