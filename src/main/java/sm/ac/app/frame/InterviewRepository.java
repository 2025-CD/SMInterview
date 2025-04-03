package sm.ac.app.frame;

import java.util.List;

public interface InterviewRepository<K,V> {
    void insert(V v) throws Exception;
    void update(V v) throws Exception;
    void delete(K k) throws Exception;
    V selectOne(K k) throws Exception;
    List<V> select() throws Exception;
}
