import java.util.List;
import java.util.ArrayList;

import processing.core.PVector;

public class QuadGraph {


    List<int[]> cycles = new ArrayList<int[]>();
    int[][] graph;

    public void build(List<PVector> lines, int width, int height) {
        
        int n = lines.size();
        
        graph = new int[n * (n + 1)/2][2];
                
        int idx =0;
        
        for (int i = 0; i < lines.size(); i++) {
            for (int j = i + 1; j < lines.size(); j++) {
                if (intersect(lines.get(i), lines.get(j), width, height)) {
                    graph[idx][0] = i;
                    graph[idx][1] = j;
                    idx++;
                }
            }
        }
 
    }

    public  boolean intersect(PVector line1, PVector line2, int width, int height) {

        double sin_t1 = Math.sin(line1.y);
        double sin_t2 = Math.sin(line2.y);
        double cos_t1 = Math.cos(line1.y);
        double cos_t2 = Math.cos(line2.y);
        float r1 = line1.x;
        float r2 = line2.x;

        double denom = cos_t2 * sin_t1 - cos_t1 * sin_t2;

        int x = (int) ((r2 * sin_t1 - r1 * sin_t2) / denom);
        int y = (int) ((-r2 * cos_t1 + r1 * cos_t2) / denom);

        if (0 <= x && 0 <= y && width >= x && height >= y)
            return true;
        else
            return false;

    }
    
    List<int[]> findCycles() {

        cycles.clear();
        for (int i = 0; i < graph.length; i++) {
            for (int j = 0; j < graph[i].length; j++) {
                findNewCycles(new int[] {graph[i][j]});
            }
        }
        for (int[] cy : cycles) {
            String s = "" + cy[0];
            for (int i = 1; i < cy.length; i++) {
                s += "," + cy[i];
            }
        }
        return cycles;
    }

    void findNewCycles(int[] path)
    {
            int n = path[0];
            int x;
            int[] sub = new int[path.length + 1];

            for (int i = 0; i < graph.length; i++)
                for (int y = 0; y <= 1; y++)
                    if (graph[i][y] == n)
                    {
                        x = graph[i][(y + 1) % 2];
                        if (!visited(x, path))
                        {
                            sub[0] = x;
                            System.arraycopy(path, 0, sub, 1, path.length);
                            findNewCycles(sub);
                        }
                        else if ((path.length == 4) && (x == path[path.length - 1]))
                        {
                            int[] p = normalize(path);
                            int[] inv = invert(p);
                            if (isNew(p) && isNew(inv))
                            {
                                cycles.add(p);
                            }
                        }
                    }
    }

     Boolean equals(int[] a, int[] b)
    {
        Boolean ret = (a[0] == b[0]) && (a.length == b.length);

        for (int i = 1; ret && (i < a.length); i++)
        {
            if (a[i] != b[i])
            {
                ret = false;
            }
        }

        return ret;
    }

     int[] invert(int[] path)
    {
        int[] p = new int[path.length];

        for (int i = 0; i < path.length; i++)
        {
            p[i] = path[path.length - 1 - i];
        }

        return normalize(p);
    }

     int[] normalize(int[] path)
    {
        int[] p = new int[path.length];
        int x = smallest(path);
        int n;

        System.arraycopy(path, 0, p, 0, path.length);

        while (p[0] != x)
        {
            n = p[0];
            System.arraycopy(p, 1, p, 0, p.length - 1);
            p[p.length - 1] = n;
        }

        return p;
    }

    Boolean isNew(int[] path)
    {
        Boolean ret = true;

        for(int[] p : cycles)
        {
            if (equals(p, path))
            {
                ret = false;
                break;
            }
        }

        return ret;
    }

     int smallest(int[] path)
    {
        int min = path[0];

        for (int p : path)
        {
            if (p < min)
            {
                min = p;
            }
        }

        return min;
    }

     Boolean visited(int n, int[] path)
    {
        Boolean ret = false;

        for (int p : path)
        {
            if (p == n)
            {
                ret = true;
                break;
            }
        }

        return ret;
    }


    public  boolean isConvex(PVector c1,PVector c2,PVector c3,PVector c4){
        
        PVector v21= PVector.sub(c1, c2);
        PVector v32= PVector.sub(c2, c3);
        PVector v43= PVector.sub(c3, c4);
        PVector v14= PVector.sub(c4, c1);
  
        float i1=v21.cross(v32).z;
        float i2=v32.cross(v43).z;
        float i3=v43.cross(v14).z;
        float i4=v14.cross(v21).z;
        
        if(   (i1>0 && i2>0 && i3>0 && i4>0) 
           || (i1<0 && i2<0 && i3<0 && i4<0))
            return true;
        else 
            return false;
   
   }

    public  boolean validArea(PVector c1,PVector c2,PVector c3,PVector c4, float max_area, float min_area){
        
        PVector v21= PVector.sub(c1, c2);
        PVector v32= PVector.sub(c2, c3);
        PVector v43= PVector.sub(c3, c4);
        PVector v14= PVector.sub(c4, c1);
  
        float i1=v21.cross(v32).z;
        float i2=v32.cross(v43).z;
        float i3=v43.cross(v14).z;
        float i4=v14.cross(v21).z;
        
        float area = Math.abs(0.5f * (i1 + i2 + i3 + i4));

        boolean valid = (area < max_area && area > min_area);   
        return valid;
   }
  

    public  boolean nonFlatQuad(PVector c1,PVector c2,PVector c3,PVector c4){
        
        float min_cos = 0.5f;
        
        PVector v21= PVector.sub(c1, c2);
        PVector v32= PVector.sub(c2, c3);
        PVector v43= PVector.sub(c3, c4);
        PVector v14= PVector.sub(c4, c1);
  
        float cos1=Math.abs(v21.dot(v32) / (v21.mag() * v32.mag()));
        float cos2=Math.abs(v32.dot(v43) / (v32.mag() * v43.mag()));
        float cos3=Math.abs(v43.dot(v14) / (v43.mag() * v14.mag()));
        float cos4=Math.abs(v14.dot(v21) / (v14.mag() * v21.mag()));
    
        if (cos1 < min_cos && cos2 < min_cos && cos3 < min_cos && cos4 < min_cos)
            return true;
        else {
            return false;
        }
   }
    

}