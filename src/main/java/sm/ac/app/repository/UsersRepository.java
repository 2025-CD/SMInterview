package sm.ac.app.repository;


import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.springframework.stereotype.Repository;
import sm.ac.app.dto.UsersDto;
import sm.ac.app.frame.InterviewRepository;

import java.util.List;

@Repository//spring container 위에 동작하기위함.
@Mapper//Mybatis framework 이동하기위한 통로이다.
public interface UsersRepository extends InterviewRepository<String, UsersDto> {
    //service에서 repository를 호출하면 하는일이 없음....
    //Mybatis가 다 해줌.
    //따라서 public class가 아닌 interface로 놓는다.
    //예전에 insert,update 이런거 다 써서 했는데 이걸 Mybatis가 해줌.

    List<UsersDto> findByName(String Name);

    int countMentorsByJobField(@Param("jobfieldid") int jobfieldid);




}
